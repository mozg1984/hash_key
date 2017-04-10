create or replace type hash_key as object (
  buffer string_buffer, -- Buffer for accumulating and keeping intermediate values
  algorithm_type varchar2(4), -- Supported algorithms {'SHA1', 'MD5'} 
    
  constructor function hash_key(p_algorithm_type in varchar2 := 'SHA1') return self as result,

  -- Set string value in buffer
  member function push(p_string_value in varchar2) return hash_key,

  -- Set number value in buffer
  member function push(p_number_value in number) return hash_key,

  -- Set date value in buffer
  member function push(p_date_value in date) return hash_key,

  -- Set LOB object in buffer
  member function push(p_clob_value in clob) return hash_key,

  -- Get hash key value by buffer and hash algorithm
  member function get return varchar2,
  
  -- Get mapped hash algorithm type number by string name of algorithm
  static function hash_algorithm(p_algorithm_type in varchar2) return number
)
