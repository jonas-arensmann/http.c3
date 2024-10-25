module http::server;

import std::io;
import std::net;
import std::net::tcp;
import std::time::datetime;

import http;

struct HttpServerRequest 
{
    KeyValuePairList headers;
    String method;
    String path;
    KeyValuePairList queries;
    String body;
}

struct HttpServerResponse
{
    uint status;
    utils::KeyValuePairList headers;
    String body;
}

struct ParseServerHeadersResult
{
    utils::KeyValuePairList headers;
    String method;
    String path;
    utils::KeyValuePairList queries;
    String body;
}

fn utils::KeyValuePairList parse_queries(String raw_query_string)
{
    utils::KeyValuePairList queries = {};

    String[] splittedQueryString = raw_query_string.split("&");

    foreach ( query : splittedQueryString )
    {
        String[] splittedQuery = query.split("=");

        queries.push({ splittedQuery[0], splittedQuery[1] });
    }

    return queries;
}

fn ParseServerHeadersResult parse_headers(String raw_headers)
{
   String[] lines = raw_headers.split("\n");
   utils::KeyValuePairList list_header;
   list_header.new_init();

    uint header_end;
    for (uint i = 0; i < utils::get_string_array_size(lines); i++) {
        if (lines[i].trim() == "") {
            header_end = i;
            break;
        }
    }

    String[] headerLines = lines[0..header_end];
    String http_header;
    foreach (index, header : lines) 
    {
        if (index == 0) 
        {
            http_header = header;
            continue;
        }

        String[] splittedHeader = header.split(":");
        String key;
        String val;
        foreach (header_key, header_value : splittedHeader) 
        {
            if (header_key == 0)
            {
                key = header_value;
            } else if (header_key == 1)
            {
                val = header_value;
            }
        
            list_header.push({key, val});
        }
    
       free(splittedHeader);
    }

    String[] splittedHttpHeader = http_header.split(" ");
    String[] splittedPath = splittedHttpHeader[1].split("?");

    utils::KeyValuePairList queries = {|
        if (utils::get_string_array_size(splittedPath) == 2) return parse_queries(splittedPath[1]);
        return {};
    |};

    DString body = dstring::new_with_capacity(utils::get_total_characters(lines[header_end + 1..]));

    if (header_end < utils::get_string_array_size(lines) - 1 && utils::get_total_characters(lines[header_end + 1..]) != 0) {
        for (uint i = header_end + 1; i < utils::get_string_array_size(lines); i++) {
            body.appendf("%s", lines[i]); 
        }
    }

    return {list_header, splittedHttpHeader[0], splittedPath[0], queries, body.copy_str()};
}


fn void create_default_server_headers(HttpServerResponse* response)
{
    if (!utils::key_exists(&response.headers, "Content-Type")) 
    {
        response.headers.push({"Content-Type", "text/plain; charset=utf-8"});
    }
    if (!utils::key_exists(&response.headers, "Server")) {
         response.headers.push({"Server", "http.c3"});
    }
    if (!utils::key_exists(&response.headers, "Date")) {
      response.headers.push({"Date", utils::datetime_as_gmt_time(datetime::now())}); 
    }
    if (!utils::key_exists(&response.headers, "Connection")) {
        response.headers.push({"Connection", "Keep-Alive"}); 
    }
    if (!utils::key_exists(&response.headers, "Cache-Control")) {
        response.headers.push({"Cache-Control", "no-cache"}); 
    }
}

def ListenCallback = fn HttpServerResponse(HttpServerRequest request);
fn void! listen(String host, uint port, ListenCallback callback) @public
{
   TcpServerSocket! serverSock = tcp::listen(host, port, 5)!;

    defer serverSock.close()!!;

    while (true) 
    {
        TcpSocket! sock = tcp::accept(&serverSock);
        if (catch err = sock)
        {
            io::printfn("Error Accepting TcpSocket: '%s'", err);
            continue;
        }
        char[2048] buf;
        if (sock.read(buf[0..])!!) { 
            String raw_headers = http::utils::char_array_to_string(buf[0..]);

            ParseServerHeadersResult parsedHeaders = parse_headers(raw_headers);

            HttpServerResponse response = callback({parsedHeaders.headers, parsedHeaders.method, parsedHeaders.path, parsedHeaders.queries, parsedHeaders.body});

            DString res = dstring::new();
            defer res.free();
	        res.reserve(2048);
	        res.appendfn("HTTP/1.1 %d OK", response.status);

            create_default_server_headers(&response);

            foreach ( header : response.headers )
            {
                res.appendfn("%s: %s", header.first, header.second);
            }

            res.append_chars("\r\n");

            res.appendf("%s\r\n", response.body);

            sock.write(res.copy_str())!!; 
            sock.close()!!;
        }
    }
}
