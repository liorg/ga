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
        context.Response.Cache.VaryByParams["t"] = true;

        string clearGif1X1 = @"R0lGODlhAQABAPcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAP8ALAAAAAABAAEAAAgEAP8FBAA7";
        string t = "";

        if (context.Request["t"] != null && !String.IsNullOrEmpty(context.Request["t"].ToString()))
        {
            t = context.Request["t"].ToString().Trim();
        }
        if (!String.IsNullOrEmpty(t))
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(@"Password=1;Persist Security Info=True;User ID=cw;Initial Catalog=imaotDb;Data Source=10.130.39.10"))
                {
                    connection.Open();
                    using (SqlCommand command = connection.CreateCommand())
                    {
                        // command.CommandText = "INSERT INTO gaTrack(gaid,track,createdon,isga,ip) VALUES(@g,@track,@c,@isga,@ip)";
                        command.CommandText = @"INSERT INTO [dbo].[RecipeViewsLogs]
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
                        command.Parameters.AddWithValue("@CookieId", Guid.NewGuid().ToString());

                        if (request.IsAuthenticated && context.User != null && context.User.Identity != null)
                            identy = context.User.Identity.Name;
                        command.Parameters.AddWithValue("@IdentityName", identy);
                        command.Parameters.AddWithValue("@IsAuthenticated", request.IsAuthenticated);

                        command.Parameters.AddWithValue("@Path", path);
                        command.Parameters.AddWithValue("@QueryString", "xxxx");
                        command.Parameters.AddWithValue("@TimeStamp", dt);

                        command.Parameters.AddWithValue("@Year", (Int16)dt.Year);
                        command.Parameters.AddWithValue("@Month", (Int16)dt.Month);

                        command.ExecuteNonQuery();

                       

                    }

                }
            }
            catch
            {

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