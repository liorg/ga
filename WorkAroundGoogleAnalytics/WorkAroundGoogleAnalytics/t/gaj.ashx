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
        {
            return ipList.Split(',')[0];
        }

        return context.Request.ServerVariables["REMOTE_ADDR"];
    }

    // static string deviceid = "";
    public void ProcessRequest(HttpContext context)
    {
        TimeSpan freshness = new TimeSpan(120, 0, 0, 0);
        context.Response.Cache.SetExpires(DateTime.Now.Add(freshness));
        context.Response.Cache.SetMaxAge(freshness);
        // context.Response.Cache.SetCacheability(HttpCacheability.Public);
        context.Response.Cache.SetCacheability(HttpCacheability.Server);
        //context.Response.Cache.VaryByParams[ConstantVariables.UserKey] = true;
        //context.Response.Cache.VaryByParams[ConstantVariables.WebsiteKey] = true;
        //context.Response.Cache.VaryByParams[ConstantVariables.AffilateKey] = true;
        //context.Response.Cache.VaryByParams[ConstantVariables.WebDealIdKey] = true;
        //context.Response.Cache.VaryByParams[ConstantVariables.MemberKey] = true;
        context.Response.Cache.VaryByParams["t"] = true;

        //     Response.AppendHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
        //Response.AppendHeader("Pragma", "no-cache"); // HTTP 1.0.
        //Response.AppendHeader("Expires", "0"); // Proxies.

        //return empty gif
        //const string clearGif1X1 = "R0lGODlhAQABAIAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==";
        string clearGif1X1 = @"R0lGODlhAQABAPcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAP8ALAAAAAABAAEAAAgEAP8FBAA7";
        string t = "";

        if (context.Request["t"] != null && !String.IsNullOrEmpty(context.Request["t"].ToString()))
        {
            t = context.Request["t"].ToString();
        }
        if (!context.Request.Browser.Crawler)
        {
            using (SqlConnection connection = new SqlConnection(@"Password=1;Persist Security Info=True;User ID=cw;Initial Catalog=imaotDb;Data Source=10.130.39.10"))
            {
                connection.Open();

                using (SqlCommand command = connection.CreateCommand())
                {

                    command.CommandText = "INSERT INTO gaTrack(gaid,track,createdon,isga,ip) VALUES(@g,@track,@c,@isga,@ip)";

                    //command.CommandText = @"INSERT INTO [dbo].[RecipeViewsLogs]
                    //                            [IpAddress] 
                    //                            ,[Browser]  ,[Platform]  ,[IsMobile] ,[IsCrawler] ,[CookieId]
                    //                            ,[IdentityName] ,[IsAuthenticated]
                    //                            ,[Path]  ,[QueryString]
                    //                            ,[TimeStamp]  ,[Year]  ,[Month])
                    //                         VALUES
                    //                               (@ip  ,@brow  ,@plat ,@IsMobile
                    //                               ,@IsCrawler ,@CookieId,  ,@IdentityName, ,@IsAuthenticated, 
                    //                               ,@Path,  ,@QueryString, 
                    //                               ,@TimeStamp, ,@Year, ,@Month)";



                    command.Parameters.AddWithValue("@track", t);
                    command.Parameters.AddWithValue("@g", Guid.NewGuid());
                    command.Parameters.AddWithValue("@c", DateTime.Now);
                    command.Parameters.AddWithValue("@isga", true);
                    command.Parameters.AddWithValue("@ip", GetUserIP(context));

                    command.ExecuteNonQuery();

                }

            }
        }
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