create or replace type string_buffer as object (
  content_ varchar2(32767),
  reserve_ clob,
  length_ number,
  overloaded_ char(1), -- ['Y', 'N']

  constructor function string_buffer return self as result,

  constructor function string_buffer(p_string in varchar2) return self as result,

  constructor function string_buffer(p_big_string in clob) return self as result,

  -- Insert string to the top of buffer
  member procedure prepend(p_string in varchar2),

  -- Insert LOB object to the top of buffer
  member procedure prepend(p_big_string in clob),

  -- Insert string at the end of buffer
  member procedure append(p_string in varchar2),

  -- Insert LOB object at the end
  member procedure append(p_big_string in clob),

  -- Reset buffer by given string
  member procedure refill(p_string in varchar2),

  -- Reset buffer by given LOB object
  member procedure refill(p_big_string in clob),

  -- Reset buffer
  member procedure reset,

  -- Get the current value of the buffer length
  member function getlength return number,

  -- Check if buffer (content) is overloaded
  member function overloaded return boolean,

  -- Get buffer content by reference
  member procedure content(p_content out nocopy varchar2),

  -- Get buffer reserve by reference
  member procedure reserve(p_reserve out nocopy clob),

  -- Expand buffer (move content to the reserve area)
  member procedure move2reserve
)
