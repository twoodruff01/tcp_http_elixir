defmodule DateFormatter do
  def to_rfc822(datetime) do
    day_name = day_name(datetime)
    day = Integer.to_string(datetime.day)
    month = month_name(datetime)
    year = Integer.to_string(datetime.year)
    time = format_time(datetime)
    timezone = "UTC"
    # timezone = "+0000"

    "#{day_name}, #{pad(day)} #{month} #{year} #{time} #{timezone}"
  end

  defp day_name(datetime) do
    case Calendar.ISO.day_of_week(datetime.year, datetime.month, datetime.day, :monday) do
      {1, 1, 7} -> "Mon"
      {2, 1, 7} -> "Tue"
      {3, 1, 7} -> "Wed"
      {4, 1, 7} -> "Thu"
      {5, 1, 7} -> "Fri"
      {6, 1, 7} -> "Sat"
      {7, 1, 7} -> "Sun"
    end
  end

  defp month_name(datetime) do
    case datetime.month do
      1 -> "Jan"
      2 -> "Feb"
      3 -> "Mar"
      4 -> "Apr"
      5 -> "May"
      6 -> "Jun"
      7 -> "Jul"
      8 -> "Aug"
      9 -> "Sep"
      10 -> "Oct"
      11 -> "Nov"
      12 -> "Dec"
    end
  end

  defp format_time(datetime) do
    format = fn num -> num |> Integer.to_string() |> String.pad_leading(2, "0") end
    hour = format.(datetime.hour)
    minute = format.(datetime.minute)
    second = format.(datetime.second)

    "#{hour}:#{minute}:#{second}"
  end

  defp pad(value) when byte_size(value) < 2, do: "0" <> value
  defp pad(value), do: value
end
