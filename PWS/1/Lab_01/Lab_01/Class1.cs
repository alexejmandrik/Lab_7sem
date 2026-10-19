using System;
using System.Collections.Generic;
using System.Web;
using System.Web.SessionState;

namespace Lab_01
{
    public class RestHandler : IHttpHandler, IRequiresSessionState
    {
        private static int _globalResult = 0;
        private static readonly object _lockObject = new object();

        private const string StackKey = "STACK";

        public bool IsReusable
        {
            get { return false; }
        }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            context.Response.ContentEncoding =
                System.Text.Encoding.UTF8;

            try
            {
                InitializeSession(context);

                switch (context.Request.HttpMethod)
                {
                    case "GET":
                        HandleGet(context);
                        break;

                    case "POST":
                        HandlePost(context);
                        break;

                    case "PUT":
                        HandlePut(context);
                        break;

                    case "DELETE":
                        HandleDelete(context);
                        break;

                    default:
                        context.Response.StatusCode = 405;
                        WriteJson(context,
                            "{\"error\":\"Method Not Allowed\"}");
                        break;
                }
            }
            catch (Exception ex)
            {
                context.Response.StatusCode = 400;

                WriteJson(context,
                    "{\"error\":\"" +
                    HttpUtility.JavaScriptStringEncode(ex.Message) +
                    "\"}");
            }
        }

        private void InitializeSession(HttpContext context)
        {
            if (context.Session[StackKey] == null)
            {
                context.Session[StackKey] = new Stack<int>();
            }
        }

        private void HandleGet(HttpContext context)
        {
            int result = _globalResult;

            Stack<int> stack =
                (Stack<int>)context.Session[StackKey];

            int finalResult = result;

            if (stack.Count > 0)
            {
                finalResult += stack.Peek();
            }

            WriteJson(context,
                "{\"RESULT\":" + finalResult + "}");
        }

        private void HandlePost(HttpContext context)
        {
            string value =
                context.Request.QueryString["RESULT"];

            if (string.IsNullOrEmpty(value))
            {
                throw new Exception(
                    "Parameter RESULT is required.");
            }

            int result;

            if (!int.TryParse(value, out result))
            {
                throw new Exception(
                    "Parameter RESULT must be an integer.");
            }

            lock (_lockObject)
            {
                _globalResult = result;
            }

            WriteJson(context,
                "{\"RESULT\":" + result + "}");
        }

        private void HandlePut(HttpContext context)
        {
            string value =
                context.Request.QueryString["ADD"];

            if (string.IsNullOrEmpty(value))
            {
                throw new Exception(
                    "Parameter ADD is required.");
            }

            int add;

            if (!int.TryParse(value, out add))
            {
                throw new Exception(
                    "Parameter ADD must be an integer.");
            }

            Stack<int> stack =
                (Stack<int>)context.Session[StackKey];

            stack.Push(add);

            int result = _globalResult;

            int finalResult =
                result + stack.Peek();

            WriteJson(context,
                "{\"RESULT\":" + finalResult + "}");
        }

        private void HandleDelete(HttpContext context)
        {
            Stack<int> stack =
                (Stack<int>)context.Session[StackKey];

            if (stack.Count == 0)
            {
                throw new Exception(
                    "Stack is empty.");
            }

            stack.Pop();

            int result = _globalResult;

            int finalResult = result;

            if (stack.Count > 0)
            {
                finalResult += stack.Peek();
            }

            WriteJson(context,
                "{\"RESULT\":" + finalResult + "}");
        }

        private void WriteJson(
            HttpContext context,
            string json)
        {
            context.Response.Write(json);
        }
    }
}