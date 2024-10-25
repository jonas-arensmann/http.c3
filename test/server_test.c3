module server_test @test;

import http::server;
import http::utils;
import std::core::string;
import std::io;

fn void! parse_queries_test() @test
{
    utils::KeyValuePairList queries = server::parse_queries("test1=test1&test2=test2");

    foreach (index, query : queries)
    {
        String current = string::format("test%d",index + 1, allocator: allocator::heap());
        assert(query.first == current);
        assert(query.second == current);
    }
}

fn void! create_default_server_headers_test() @test
{
    server::HttpServerResponse response = {};
    server::create_default_server_headers(&response);
    assert(utils::key_exists(&response.headers, "Content-Type"));
    assert(utils::key_exists(&response.headers, "Server"));
    assert(utils::key_exists(&response.headers, "Date"));
    assert(utils::key_exists(&response.headers, "Connection"));
    assert(utils::key_exists(&response.headers, "Cache-Control"));

    server::HttpServerResponse response2 = {};
    response2.headers.push({"content-type", "text/html"});
    server::create_default_server_headers(&response2);
    assert(utils::key_exists(&response2.headers, "Content-Type"));
    assert(utils::get_by_key(&response2.headers, "Content-Type")! == "text/html");
    assert(utils::key_exists(&response2.headers, "Server"));
    assert(utils::key_exists(&response2.headers, "Date"));
    assert(utils::key_exists(&response2.headers, "Connection"));
    assert(utils::key_exists(&response2.headers, "Cache-Control"));
}
