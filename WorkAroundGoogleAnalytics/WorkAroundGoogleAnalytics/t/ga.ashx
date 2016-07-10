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
        context.Response.ContentType = "application/json";
        context.Response.AppendHeader("Access-Control-Allow-Origin", "*");
        context.Response.AppendHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS, HEAD");
        context.Response.AppendHeader("Access-Control-Allow-Headers", "X-Requested-With");
        string t = "";

        if (context.Request["t"] != null && !String.IsNullOrEmpty(context.Request["t"].ToString()))
        {
            t = context.Request["t"].ToString();
        }
        using (SqlConnection connection = new SqlConnection(@"Password=1;Persist Security Info=True;User ID=cw;Initial Catalog=imaotDb;Data Source=10.130.39.10"))
        {
            connection.Open();

            using (SqlCommand command = connection.CreateCommand())
            {
                //if (t == "88810" || t == "88849")
                {

                    command.CommandText = "INSERT INTO gaTrack(gaid,track,createdon,isga,ip) VALUES(@g,@track,@c,@isga,@ip)";
                    command.Parameters.AddWithValue("@track", t);
                    command.Parameters.AddWithValue("@g", Guid.NewGuid());
                    command.Parameters.AddWithValue("@c", DateTime.Now);
                    command.Parameters.AddWithValue("@isga", true);
                    command.Parameters.AddWithValue("@ip", GetUserIP(context));


                    command.ExecuteNonQuery();
                }
            }
        }
        context.Response.Write("ok");
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}