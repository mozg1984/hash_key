create or replace type body hash_key as

  constructor function hash_key(p_algorithm_type in varchar2 := 'SHA1') return self as result
  is
  begin
    -- check given hash algorithm
    if (hash_key.hash_algorithm(p_algorithm_type) is null) then
      raise_application_error(-20000, 'Given algorithm is not supported');
    end if;
    
    algorithm_type := upper(p_algorithm_type);    
    buffer := string_buffer();
    return;
  end;

  member function push(p_string_value in varchar2 default null) return hash_key
  is
    l_object hash_key := self;
  begin
    l_object.buffer.append(p_string_value);
    return l_object;
  end;
  
  member procedure push(p_string_value in varchar2 default null)
  is
  begin
    buffer.append(p_string_value);
  end;

  member function push(p_number_value in number) return hash_key
  is
    l_object hash_key := self;
  begin
    l_object.buffer.append(to_char(p_number_value));
    return l_object;
  end;
  
  member procedure push(p_number_value in number)
  is
  begin
    buffer.append(to_char(p_number_value));
  end;

  member function push(p_date_value in date) return hash_key
  is
    l_object hash_key := self;
  begin
    l_object.buffer.append(to_char(p_date_value, hash_key.date_format));
    return l_object;
  end;
  
  member procedure push(p_date_value in date)
  is
  begin
    buffer.append(to_char(p_date_value, hash_key.date_format));
  end;

  member function push(p_clob_value in clob) return hash_key
  is
    l_object hash_key := self;
  begin
    l_object.buffer.append(p_clob_value);
    return l_object;
  end;
  
  member procedure push(p_clob_value in clob)
  is
  begin
    buffer.append(p_clob_value);
  end;

  member function get return varchar2
  is
    l_self hash_key := self;
    l_content l_self.buffer.content_%type;
    l_reserve l_self.buffer.reserve_%type;
    l_hash_algorithm number;
  begin
    -- identificate hash algorithm   
    l_hash_algorithm := hash_key.hash_algorithm(algorithm_type);
    if (l_hash_algorithm is null) then return null; end if;
      
    if (not buffer.overloaded()) then
      l_self.buffer.content(l_content);
      return dbms_crypto.hash(utl_raw.cast_to_raw(l_content), l_hash_algorithm);
    else
      l_self.buffer.reserve(l_reserve);
      return dbms_crypto.hash(l_reserve, l_hash_algorithm);
    end if;
  end;
  
  static function date_format return varchar2
  is
  begin
    return 'dd:mm:yyyy:hh24:mi:ss';
  end;
  
  static function hash_algorithm(p_algorithm_type in varchar2) return number
  is
  begin
    if (upper(p_algorithm_type) = 'SHA1') then
        return dbms_crypto.hash_sh1;
    end if;
    
    if (upper(p_algorithm_type) = 'MD5') then
        return dbms_crypto.hash_md5;
    end if;
    
    return null;
  end;
end;
