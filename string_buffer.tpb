create or replace type body string_buffer as

  constructor function string_buffer return self as result
  is
  begin
    content_ := '';
    length_ := 0;
    overloaded_ := 'N';
    return;
  end;

  constructor function string_buffer(p_string in varchar2) return self as result
  is
  begin
    content_ := p_string;
    length_ := nvl(length(p_string), 0);
    overloaded_ := 'N';
    return;
  end;

  constructor function string_buffer(p_big_string in clob) return self as result
  is
  begin
    content_ := '';
    dbms_lob.createtemporary(reserve_, true, dbms_lob.session);
    reserve_ := p_big_string;
    overloaded_ := 'Y';
    return;
  end;

  member procedure prepend(p_string in varchar2)
  is
  begin
    if (not overloaded() and (nvl(length(content_), 0) + nvl(length(p_string), 0) > 32767)) then
      move2reserve();
    end if;

    if overloaded() then
      reserve_ := to_clob(p_string) || reserve_;
      length_ := dbms_lob.getlength(reserve_);
    else
      content_ := p_string || content_;
      length_ := length(content_);
    end if;
  end;

  member procedure prepend(p_big_string in clob)
  is
  begin
    if (not overloaded()) then
      move2reserve();
    end if;

    reserve_ := p_big_string || reserve_;
    length_ := dbms_lob.getlength(reserve_);
  end;

  member procedure append(p_string in varchar2)
  is
  begin
    if (not overloaded() and (nvl(length(content_), 0) + nvl(length(p_string), 0) > 32767)) then
      move2reserve();
    end if;

    if overloaded() then
      reserve_ := reserve_ || to_clob(p_string);
      length_ := dbms_lob.getlength(reserve_);
    else
      content_ := content_ || p_string;
      length_ := length(content_);
    end if;
  end;

  member procedure append(p_big_string in clob)
  is
  begin
    if (not overloaded()) then
      move2reserve();
    end if;

    reserve_ := reserve_ || p_big_string;
    length_ := dbms_lob.getlength(reserve_);
  end;

  member procedure refill(p_string in varchar2)
  is
  begin
    reset();
    append(p_string);
  end;

  member procedure refill(p_big_string in clob)
  is
  begin
    reset();
    append(p_big_string);
  end;

  member procedure reset
  is
  begin
    content_ := '';
    length_ := 0;

    if (dbms_lob.istemporary(reserve_) = 1) then
      dbms_lob.freetemporary(reserve_);
    end if;

    overloaded_ := 'N';
  end;

  member function getlength return number
  is
  begin
    return length_;
  end;

  member function overloaded return boolean
  is
  begin
    return overloaded_ = 'Y';
  end;

  member procedure content(p_content out nocopy varchar2)
  is
  begin
    p_content := content_;
  end;

  member procedure reserve(p_reserve out nocopy clob)
  is
  begin
    if overloaded() then
      p_reserve := reserve_;
    end if;
  end;

  member procedure move2reserve
  is
  begin
    dbms_lob.createtemporary(reserve_, true, dbms_lob.session);
    reserve_ := to_clob(content_);
    content_ := '';
    overloaded_ := 'Y';
  end;
end;
