<%@ WebHandler Language="C#" Class="Ping" %>

using System;
using System.Web;
using System.Net;
using System.IO;
using System.Data;
using System.Data.SqlClient;
public class Ping : IHttpHandler
{
    private string GetUserIP(HttpContext context)
    {
        string ipList = context.Request.ServerVariables["HTTP_X_FORWARDED_FOR"];
        if (!string.IsNullOrEmpty(ipList))
            return ipList.Split(',')[0];
        return context.Request.ServerVariables["REMOTE_ADDR"];
    }

    public void TrackEvent(string ip, string agent, string repid, string qt, string cid)
    {
        var domain = "imaot.co.il";
        var title = "Recipe Num " + repid;

        System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();
        string postData = "v=1&tid=UA-41590038-1&cid=" + cid + "&t=pageview&dh="
                + domain + "&dt=" + title + "&qt=" + qt + "&uip=" + ip + "&ua=" + agent + "&dp=Book/Page/" + repid;
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

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        context.Response.Cache.SetNoStore();

        string t = "";
        string timeout = "500";
        string responseLog = "ok";
        string cokname = "";
        string random = "";
        string action = "";
        string track = "no";
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

        if (random == "")
        {
            int randomvar = new Random().Next(int.MinValue, int.MaxValue);
            random = "my_" + randomvar.ToString();
        }
        if (cokname == "")
            cokname = "my_" + Guid.NewGuid().ToString();

        if (cokname.StartsWith("gog_ip_"))
            cokname = cokname + "." + random;

        if (!String.IsNullOrEmpty(t))
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(@"Password=1;Persist Security Info=True;User ID=cw;Initial Catalog=imaotDb;Data Source=10.130.39.10"))
                {
                    connection.Open();
                    using (SqlCommand command = connection.CreateCommand())
                    {
                        command.CommandText = @"INSERT INTO [dbo].[gaTrack]
                                              ( [RecipeId], [IpAddress] 
                                                ,[Browser]  ,[Platform]  ,[IsMobile] ,[IsCrawler] ,[CookieId]
                                                ,[IdentityName] ,[IsAuthenticated]
                                                ,[Path]  ,[QueryString]
                                                ,[TimeStamp]  ,[Year]  ,[Month],[Track])
                                             VALUES
                                                   (@RecipeId,@ip 
                                                   ,@brow  ,@plat ,@IsMobile  ,@IsCrawler 
                                                   ,@CookieId, @IdentityName ,@IsAuthenticated
                                                   ,@Path,  @QueryString
                                                   ,@TimeStamp, @Year ,@Month,@Track)";

                        var request = context.Request;

                        var getip = GetUserIP(context);
                        var identy = "";
                        var path = "/Book/Page/" + t;
                        var dt = DateTime.Now;
                        command.Parameters.AddWithValue("@RecipeId", int.Parse(t));
                        command.Parameters.AddWithValue("@ip", getip);
                        command.Parameters.AddWithValue("@brow", request.Browser.Browser + " " + request.Browser.Version);
                        command.Parameters.AddWithValue("@plat", request.Browser.Platform);
                        command.Parameters.AddWithValue("@IsMobile", request.Browser.IsMobileDevice);
                        command.Parameters.AddWithValue("@IsCrawler", request.Browser.Crawler);
                        command.Parameters.AddWithValue("@CookieId", cokname);

                        if (request.IsAuthenticated && context.User != null && context.User.Identity != null)
                            identy = context.User.Identity.Name;

                        command.Parameters.AddWithValue("@IdentityName", identy);
                        command.Parameters.AddWithValue("@IsAuthenticated", request.IsAuthenticated);

                        command.Parameters.AddWithValue("@Path", path);
                        command.Parameters.AddWithValue("@QueryString", "googlex(" + timeout + "," + action + ")");
                        command.Parameters.AddWithValue("@TimeStamp", dt);

                        command.Parameters.AddWithValue("@Year", (Int16)dt.Year);
                        command.Parameters.AddWithValue("@Month", (Int16)dt.Month);

                        command.Parameters.AddWithValue("@Track", track);

                        command.ExecuteNonQuery();

                        try
                        {
                            if (track == "yes" && request.Browser != null && !request.Browser.Crawler)
                                TrackEvent(getip, context.Request.UserAgent, t, timeout, cokname);
                        }
                        catch (Exception ex) { responseLog = responseLog + " " + ex.ToString(); }

                    }
                }
            }
            catch (Exception e) { responseLog = responseLog + " " + e.ToString(); }
        }

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