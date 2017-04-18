declare
  /*
  Note: for execute this unit test you should use next package:
        https://github.com/mozg1984/dbunit 
  */
  
  hash_key_val1 hash_key;
  hash_key_val2 hash_key;
  hash_key_val3 hash_key;
  string_val varchar2(32767) := '';
  clob_val clob;
begin
  
  begin
    hash_key_val1 := hash_key('UNKNOWN');
  exception
    when others then dbunit.assert_equals(sqlcode, -20000, 'Unknown hash algorithm exception'); 
  end;
  
  dbunit.assert_null(hash_key().get(), 'EMPTY HASH KEY VALUE IS NOT NULL');
  
  dbunit.assert_equals(
    hash_key()
      .push('one')
      .push(to_char(null))
      .push('two')
      .push(to_number(null))
      .push('three')
      .push(to_date(null))
      .get(),
    hash_key('sha1')
      .push(to_clob(null))
      .push('one')
      .push('two')
      .push(to_clob('three'))
      .get()
  );
   
  dbunit.assert_equals(
    hash_key().push('one').push('two').push('three').get(),
    hash_key('sha1').push('one').push('two').push('three').get()
  );
  
  string_val := 'one' || 'two' || 'three';
  dbunit.assert_equals(
    hash_key().push('one').push('two').push('three').get(),
    dbms_crypto.hash(utl_raw.cast_to_raw(string_val), dbms_crypto.hash_sh1)
  );
  
  string_val := 'one' || 'two' || 'three';
  dbunit.assert_equals(
    hash_key('md5').push('one').push('two').push('three').get(),
    dbms_crypto.hash(utl_raw.cast_to_raw(string_val), dbms_crypto.hash_md5)
  );
  
  string_val := '1' || 'two' || to_char(sysdate, hash_key.date_format);
  dbunit.assert_equals(
    hash_key().push(1).push('two').push(sysdate).get(),
    dbms_crypto.hash(utl_raw.cast_to_raw(string_val), dbms_crypto.hash_sh1)
  );
  
  string_val := '1' || 'two' || to_char(sysdate, hash_key.date_format);
  dbunit.assert_equals(
    hash_key('md5').push(1).push('two').push(sysdate).get(),
    dbms_crypto.hash(utl_raw.cast_to_raw(string_val), dbms_crypto.hash_md5)
  );
  
  hash_key_val2 := hash_key('sha1');
  hash_key_val3 := hash_key('md5');
  for i in 1..100 loop
    string_val := dbms_random.string('U', 1000);
    clob_val := clob_val || string_val;
    
    hash_key_val2.push(string_val);
    hash_key_val3.push(to_clob(string_val));
  end loop;
  
  dbunit.assert_not_null(clob_val);
  
  dbunit.assert_equals(
    hash_key_val2.get(),
    dbms_crypto.hash(clob_val, dbms_crypto.hash_sh1)
  );
  
   dbunit.assert_equals(
    hash_key_val3.get(),
    dbms_crypto.hash(clob_val, dbms_crypto.hash_md5)
  );
  
  dbunit.assert_equals(
    hash_key('sha1').push(clob_val).get(),
    dbms_crypto.hash(clob_val, dbms_crypto.hash_sh1)
  );
  
  dbunit.assert_equals(
    hash_key('md5').push(clob_val).get(),
    dbms_crypto.hash(clob_val, dbms_crypto.hash_md5)
  );
end;
