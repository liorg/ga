<%@ WebHandler Language="C#" Class="LogsGoo2" %>

using System;
using System.Web;
using System.Net;
using System.IO;
using System.Collections;
using System.Linq;
using System.Collections.Generic;
using System.Collections.Concurrent;
using System.Data;
using System.Data.SqlClient;
using System.Threading;
using System.Threading.Tasks;
public class LogsGoo2 : IHttpHandler
{
    class Logger
    {
        static object _lock = new object();
        static ConcurrentDictionary<string, LogModel> _timeoutData = new ConcurrentDictionary<string, LogModel>();

        void TrackEvent(string ip, string agent, string repid, string qt, string cid, string title)
        {
            var domain = "imaot.co.il";
            var t = Uri.EscapeDataString(title);
            System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();
            string postData = "v=1&tid=UA-57229912-1&cid=" + cid + "&t=pageview&dh="
                    + domain + "&dt=" + t + "&qt=" + qt + "&uip=" + ip + "&ua=" + agent + "&dp=Book/Page/" + repid;
            byte[] data = encoding.GetBytes(postData);
            HttpWebRequest myRequest = (HttpWebRequest)WebRequest.Create("http://www.google-analytics.com/collect");
            myRequest.Method = "POST";
            myRequest.ContentType = "application/x-www-form-urlencoded";
            myRequest.ContentLength = data.Length;
            using (Stream newStream = myRequest.GetRequestStream())
            {
                newStream.Write(data, 0, data.Length);
                newStream.Close();
            }
        }
        public void ExpriedLogs()
        {
            lock (_lock)
            {
                Queue<string> sessions = new Queue<string>();
                DateTime cu = DateTime.Now;
                var expList = _timeoutData.Values.Where(log => log.exdt < cu);
                foreach (var expirLog in expList)
                {
                    TimeSpan ts = cu - expirLog.exdt;
                     expirLog.action="TimeoutHappened("+ts.Seconds.ToString()+"s)";
                    LogAndTrack(expirLog);
                    sessions.Enqueue(expirLog.sessionId);
                }
                do
                {
                    var sessionid = sessions.Dequeue();
                    LogModel logTemp;
                    _timeoutData.TryRemove(sessionid, out logTemp);
                    // process the customers request 
                } while (sessions.Count != 0);
            }

        }
        public string LogAndTrack(LogModel log)
        {
            string title = "",
                    responseLog = "OK";
            if (log.action == "TimeoutHappened")
            {
                log.action = "TimeoutHappened(waiting..)";
                _timeoutData.TryAdd(log.sessionId, log);
                return responseLog + " " + log.sessionId + " add to timeout";
            }
            LogModel logTemp;
            _timeoutData.TryRemove(log.sessionId, out logTemp);
            if (logTemp != null)
                responseLog = responseLog + " " + log.sessionId + " remove it..";
            
            try
            {
                SqlCommand command = null;
                using (SqlConnection connection = new SqlConnection(@"Password=1;Persist Security Info=True;User ID=cw;Initial Catalog=imaotDb;Data Source=10.130.39.10"))
                {
                    connection.Open();
                    using (command = connection.CreateCommand())
                    {
                        command.CommandText = @"INSERT INTO [dbo].[gaTrack]
                                              ( [RecipeId], [IpAddress] 
                                                ,[Browser]  ,[Platform]  ,[IsMobile] ,[IsCrawler] ,[CookieId]
                                                ,[IdentityName] ,[IsAuthenticated]
                                                ,[Path]  ,[QueryString]
                                                ,[TimeStamp]  ,[Year]  ,[Month])
                                             VALUES
                                                   (@RecipeId,@ip 
                                                   ,@brow  ,@plat ,@IsMobile  ,@IsCrawler 
                                                   ,@CookieId, @IdentityName ,@IsAuthenticated
                                                   ,@Path,  @QueryString
                                                   ,@TimeStamp, @Year ,@Month)";

                        command.Parameters.AddWithValue("@RecipeId", log.rapid);
                        command.Parameters.AddWithValue("@ip", log.getip);
                        command.Parameters.AddWithValue("@brow", log.brow);
                        command.Parameters.AddWithValue("@plat", log.plat);
                        command.Parameters.AddWithValue("@IsMobile", log.isMobile);
                        command.Parameters.AddWithValue("@IsCrawler", log.isCrawler);
                        command.Parameters.AddWithValue("@CookieId", log.cokname);

                        command.Parameters.AddWithValue("@IdentityName", log.identy);
                        command.Parameters.AddWithValue("@IsAuthenticated", log.isAuthenticated);
                        command.Parameters.AddWithValue("@Path", log.path);
                        command.Parameters.AddWithValue("@QueryString", "qv3," + log.sessionId + "," + log.action + "");
                        command.Parameters.AddWithValue("@TimeStamp", log.dt);
                        command.Parameters.AddWithValue("@Year", (Int16)log.dt.Year);
                        command.Parameters.AddWithValue("@Month", (Int16)log.dt.Month);

                        command.ExecuteNonQuery();

                        try
                        {
                            if (log.track == "yes" && !log.isCrawler)
                                TrackEvent(log.getip, log.userAgent, log.t, log.timeout, log.cokname, title);
                        }
                        catch (Exception ex) { responseLog = responseLog + " " + ex.ToString(); }
                    }
                }
            }
            catch (Exception e) { responseLog = responseLog + " " + e.ToString(); }
            return responseLog;

        }
    }

    public class LogModel
    {
        const double maxMinExpiredLog = 1;
        private string GetUserIP(HttpContext context)
        {
            string ipList = context.Request.ServerVariables["HTTP_X_FORWARDED_FOR"];
            if (!string.IsNullOrEmpty(ipList))
                return ipList.Split(',')[0];
            return context.Request.ServerVariables["REMOTE_ADDR"];
        }

        public LogModel(HttpContext context)
        {
            timeout = "500";
            random = "";
            if (context.Request["t"] != null && !String.IsNullOrEmpty(context.Request["t"].ToString()))
                t = context.Request["t"].ToString();

            if (context.Request["h"] != null && !String.IsNullOrEmpty(context.Request["h"].ToString()))
                timeout = context.Request["h"].ToString();

            if (context.Request["a"] != null && !String.IsNullOrEmpty(context.Request["a"].ToString()))
                action = context.Request["a"].ToString();

            if (context.Request["c"] != null && !String.IsNullOrEmpty(context.Request["c"].ToString()))
                cokname = context.Request["c"].ToString();

            if (context.Request["r"] != null && !String.IsNullOrEmpty(context.Request["r"].ToString()))
                random = context.Request["r"].ToString();

            if (context.Request["ta"] != null && !String.IsNullOrEmpty(context.Request["ta"].ToString()))
                track = context.Request["ta"].ToString();

            if (context.Request["ses"] != null && !String.IsNullOrEmpty(context.Request["ses"].ToString()))
                sessionId = context.Request["ses"].ToString();

            if (context.Request["lo"] != null && !String.IsNullOrEmpty(context.Request["lo"].ToString()))
                load = context.Request["lo"].ToString();

            if (random == "")
            {
                // int randomvar = new Random().Next(int.MinValue, int.MaxValue);
                random = "myrandom_" + Guid.NewGuid().ToString();// randomvar.ToString();
            }
            if (cokname == "")
                cokname = "mycokname_" + Guid.NewGuid().ToString();
            
            var request = context.Request;
            getip = GetUserIP(context);
            identy = "";
            path = "/Book/Page/" + t;
            dt = DateTime.Now;
            rapid = int.Parse(t);

            if (request.IsAuthenticated && context.User != null && context.User.Identity != null)
                identy = context.User.Identity.Name;

            brow = request.Browser.Browser + " " + request.Browser.Version;
            isMobile = request.Browser.IsMobileDevice;
            isCrawler = request.Browser.Crawler;
            isAuthenticated = request.IsAuthenticated;
            userAgent = request.UserAgent;
            plat = request.Browser.Platform;
            exdt = dt.AddMinutes(maxMinExpiredLog);
        }
        public string t { get; set; }
        public int rapid { get; set; }
        public DateTime dt { get; set; }
        public DateTime exdt { get; set; }
        public string getip { get; set; }
        public string identy { get; set; }
        public string cokname { get; set; }
        public string random { get; set; }
        public string action { get; set; }
        public string track { get; set; }
        public string sessionId { get; set; }
        public string load { get; set; }

        public string timeout { get; set; }
        public string brow { get; set; }
        public string plat { get; set; }
        public bool isMobile { get; set; }
        public bool isCrawler { get; set; }

        public bool isAuthenticated { get; set; }
        public string path { get; set; }
        public string userAgent { get; set; }
    }




    private static object obj = new object();

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        context.Response.Cache.SetNoStore();
        LogModel log = new LogModel(context);
        Logger logger = new Logger();
        var responseLog = logger.LogAndTrack(log);
        Task.Run(() =>
        {
            Logger loggerExpired = new Logger();
            loggerExpired.ExpriedLogs();
        });
        context.Response.Write(responseLog);
    }
    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}