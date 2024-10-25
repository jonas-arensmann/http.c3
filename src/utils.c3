module http::utils;

import std::time::datetime;
import std::time;
import std::collections::list;
import std::collections::tuple;

def KeyValuePair = tuple::Tuple(<String, String>);
def KeyValuePairList = List(<KeyValuePair>);

fn String char_array_to_string(char[] char_array) 
{
   return string::format((String)char_array[0..], allocator: allocator::temp());
}

fn uint get_string_array_size(String[] array)
{
    uint count = 0;
    foreach (i, v : array)
    {
        count++;
    }

    return count;
}

fn usz get_total_characters(String[] array) 
{
    usz total_characters = 0; 
    foreach (string : array) {
      total_characters += string.zstr_copy().len(); 
    }

    return total_characters;
}

fn String datetime_as_gmt_time(DateTime date) 
{
   String weekday_str;
   switch (date.weekday) 
   {
      case time::Weekday.MONDAY: weekday_str = "Mon"; break;
      case time::Weekday.TUESDAY: weekday_str = "Tue"; break;
      case time::Weekday.WEDNESDAY: weekday_str = "Wed"; break;
      case time::Weekday.THURSDAY: weekday_str = "Thu"; break;
      case time::Weekday.FRIDAY: weekday_str = "Fri"; break;
      case time::Weekday.SATURDAY: weekday_str = "Sat"; break;
      case time::Weekday.SUNDAY: weekday_str = "Sun"; break;
   }

   return string::format("%s, %d %s %d %.2d:%.2d:%.2d GMT", 
      weekday_str,
      date.day, 
      (int)date.month + 1, 
      date.year, 
      date.hour, 
      date.min, 
      date.sec, 
      allocator: allocator::temp());
}

fn bool key_exists(KeyValuePairList* list, String key) 
{
   foreach (item : list)
   {
      if (to_lowercase(item.first) == to_lowercase(key))
      {
         return true;
      }
   }
   return false;
}

fault GetByKeyResult
{
   NOT_FOUND
}

fn String! get_by_key(KeyValuePairList* list, String key)
{
   foreach (item : list)
   {
      if (to_lowercase(item.first) == to_lowercase(key))
      {
         return item.second;
      }
   }
   return GetByKeyResult.NOT_FOUND?;
}

fn String to_lowercase(String str)
{
    String lower = String.copy(str);
    lower.convert_ascii_to_lower();
    return lower;
}
