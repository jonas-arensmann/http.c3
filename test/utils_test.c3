module utils_test @test;

import http::utils;
import std::core::string;
import std::core::builtin;
import std::time::datetime;
import std::time;

fn void! char_array_to_string_test() @test {
    char[] char_array = "test";
    String expected_string = "test";
    String result_string = utils::char_array_to_string(char_array);
    assert(result_string == expected_string);
}

fn void! get_string_array_size_test() @test {
    String[] string_array = { "test1", "test2", "test3" };
    uint expected_size = 3;
    uint result_size = utils::get_string_array_size(string_array);
    assert(result_size == expected_size);
}

fn void! get_total_characters_test() @test
{
    String[] strings = { "test", "test2", "test3" };

    assert(utils::get_total_characters(strings) == 14);
}

fn void! datetime_as_gmt_time_test() @test
{
    DateTime date = datetime::from_date(2024, time::Month.OCTOBER, 17, 19, 05, 00);
    String gmt = utils::datetime_as_gmt_time(date);
    assert(gmt == "Sat, 17 10 2024 19:05:00 GMT");
}

fn void! key_exists_test() @test
{
    utils::KeyValuePairList list = {};
    list.push({"test_key1", "test_value1"});
    list.push({"test1", "test2"});

    assert(utils::key_exists(&list, "test_key1") == true);
    assert(utils::key_exists(&list, "test_key2") == false);
}

fn void! get_by_key_test() @test
{
    utils::KeyValuePairList list = {};
    list.push({"test_key1", "test_value1"});
    list.push({"test", "test2"});

    assert(utils::get_by_key(&list, "test_key1")! == "test_value1");
    
    if (catch err = utils::get_by_key(&list, "test_key2"))
    {
        if (err != utils::GetByKeyResult.NOT_FOUND)
        {
            builtin::panic("Expected NOT_FOUND", $$FILE, $$FUNC, $$LINE);
        }
    } else {
        builtin::panic("Expected NOT_FOUND", $$FILE, $$FUNC, $$LINE);
    }
}

fn void! to_lowercase_test() @test
{
    String str = "TEST_STRING";

    assert(utils::to_lowercase(str) == "test_string");
}