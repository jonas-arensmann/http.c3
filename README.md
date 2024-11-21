# http.c3

This module provides a **very** simple HTTP server implementation in C3.

> Not usable for any production like environments

## Usage

The `http::server::listen` function can be used to start a new HTTP server. It takes three arguments:

* `host`: The hostname or IP address to listen on.
* `port`: The port number to listen on.
* `callback`: A callback function that will be called for each incoming request.

The callback function should take an `HttpServerRequest` object as an argument and return an `HttpResponse` object.

## HttpServerRequest Object

The `HttpServerRequest` object contains information about the incoming HTTP request, including:

* `headers`: A list of key-value pairs representing the HTTP headers.
* `method`: The HTTP method (e.g., "GET", "POST").
* `path`: The requested path.
* `queries`: A list of key-value pairs representing the query parameters.
* `body`: The request body (if any).

## HttpServerResponse Object

The `HttpServerResponse` object represents the HTTP response that will be sent to the client. It contains the following fields:

* `status`: The HTTP status code (e.g., 200, 404).
* `headers`: A list of key-value pairs representing the HTTP headers.
* `body`: The response body.

## Example

```c3
import std::io;
import http::server;

fn server::HttpServerResponse callback(server::HttpServerRequest request)
{
    // Status, Headers, Body
    server::HttpServerResponse response = {http::HttpStatus.OK, {}, "Hello World!"};
    return response;
}

fn void main() 
{
    server::listen("0.0.0.0", 8080, &callback)!!;
}
```
