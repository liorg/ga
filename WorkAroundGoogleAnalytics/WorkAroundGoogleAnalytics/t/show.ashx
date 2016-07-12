<%@ WebHandler Language="C#" Class="Ping" %>

using System;
using System.Web;
using System.Net;
using System.IO;
using System.Data;
using System.Data.SqlClient;
public class Ping : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        context.Response.AppendHeader("Access-Control-Allow-Origin", "*");
        context.Response.AppendHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS, HEAD");
        context.Response.AppendHeader("Access-Control-Allow-Headers", "X-Requested-With");
        string t = "";

        var response = "0";
        if (context.Request["t"] != null && !String.IsNullOrEmpty(context.Request["t"].ToString()))
        {
            t = context.Request["t"].ToString();
        }
        using (SqlConnection connection = new SqlConnection(@"Password=1;Persist Security Info=True;User ID=cw;Initial Catalog=imaotDb;Data Source=10.130.39.10"))
        {
            connection.Open();
            using (SqlCommand command = connection.CreateCommand())
            {

                command.CommandText = "select count(*) from [imaotDb].[dbo].[gaTrack] where  RecipeId=@track";
                command.Parameters.AddWithValue("@track", t);
                try
                {
                    object count = command.ExecuteScalar();
                    response = count.ToString();
                }
                catch (Exception e)
                {

                }
            }
        }
        context.Response.Write(response);
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}