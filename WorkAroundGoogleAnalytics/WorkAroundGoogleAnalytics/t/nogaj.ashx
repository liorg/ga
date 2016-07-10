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

    public void TrackEvent(string ip, string agent, string repid, string qt)
    {
        var domain = "imaot.co.il";
        System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();
        string postData = "v=1&tid=UA-80360653-1&cid=" + Guid.NewGuid().ToString() + "&t=pageview&dh="
                + domain + "&qt=" + qt + "&uip=" + ip + "&ua=" + agent + "&dp=Book/Page/" + repid;
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

    // static string deviceid = "";
    public void ProcessRequest(HttpContext context)
    {
        TimeSpan freshness = new TimeSpan(120, 0, 0, 0);
        context.Response.Cache.SetExpires(DateTime.Now.Add(freshness));
        context.Response.Cache.SetMaxAge(freshness);
        context.Response.Cache.SetCacheability(HttpCacheability.Server);
        context.Response.Cache.VaryByParams["t"] = true;

        string clearGif1X1 = @"R0lGODlhAQABAPcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAP8ALAAAAAABAAEAAAgEAP8FBAA7";
        string t = "";
        string timeout = "500";
        if (context.Request["t"] != null && !String.IsNullOrEmpty(context.Request["t"].ToString()))
        {
            t = context.Request["t"].ToString();
        }
        if (context.Request["h"] != null && !String.IsNullOrEmpty(context.Request["h"].ToString()))
        {
            timeout = context.Request["h"].ToString();
        }
        if (!context.Request.Browser.Crawler)
        {
            using (SqlConnection connection = new SqlConnection(@"Password=1;Persist Security Info=True;User ID=cw;Initial Catalog=imaotDb;Data Source=10.130.39.10"))
            {
                connection.Open();

                using (SqlCommand command = connection.CreateCommand())
                {
                    var ip = GetUserIP(context);

                    command.CommandText = "INSERT INTO gaTrack(gaid,track,createdon,isga,ip) VALUES(@g,@track,@c,@isga,@ip)";
                    command.Parameters.AddWithValue("@track", t);
                    command.Parameters.AddWithValue("@g", Guid.NewGuid());
                    command.Parameters.AddWithValue("@c", DateTime.Now);
                    command.Parameters.AddWithValue("@isga", false);
                    command.Parameters.AddWithValue("@ip", ip);

                    command.ExecuteNonQuery();
                    try
                    {
                        TrackEvent(ip, context.Request.UserAgent, t, timeout);
                    }
                    catch { }

                }
            }
        }
        // context.Response.Write("ok");
        context.Response.ContentType = "image/png";

        var bytes = Convert.FromBase64String(clearGif1X1);
        context.Response.OutputStream.Write(bytes, 0, bytes.Length);
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}