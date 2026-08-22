-- ============================================================================
-- the basics
DECLARE @Vector XML = '
<vectors>
  <vector>
    <x>2</x>
    <y>3</y>
  </vector>
  <vector>
    <x>5</x>
    <y>7</y>
  </vector>
</vectors>
'

SELECT @Vector.query('.')
-- RETURNS: <vectors><vector><x>2</x><y>3</y></vector><vector><x>5</x><y>7</y></vector></vectors>

SELECT c.query('.') FROM @Vector.nodes('.') t (c) -- Unchanged. A dot makes no change.

SELECT c.query('.') FROM @Vector.nodes('vectors') t (c) -- Unchanged. Vectors is the only tag at the current level. So it returns everything.

SELECT c.query('.') FROM @Vector.nodes('*') t (c) -- Unchanged. Nodes-star is the same as nodes('vectors').

SELECT c.query('*') FROM @Vector.nodes('*') t (c) -- Nodes-star matches "vectors". Query-star matches "vector". So it returns everything.
-- RETURNS: <vector><x>2</x><y>3</y></vector><vector><x>5</x><y>7</y></vector>

SELECT c.query('.') FROM @Vector.nodes('*/*') t (c) -- Nodes-star-star is the same as nodes('vector/vectores')
-- RETURNS: <vector><x>2</x><y>3</y></vector>
--          <vector><x>5</x><y>7</y></vector>

SELECT c.query('..') FROM @Vector.nodes('*/*') t (c) -- dot dot means go back a level
-- RETURNS: <vectors><vector><x>2</x><y>3</y></vector><vector><x>5</x><y>7</y></vector></vectors>
--          <vectors><vector><x>2</x><y>3</y></vector><vector><x>5</x><y>7</y></vector></vectors>

SELECT c.query('*') FROM @Vector.nodes('*/*') t (c) 
-- RETURNS: <x>2</x><y>3</y>
--          <x>5</x><y>7</y>

SELECT c.query('*') FROM @Vector.nodes('vectors/vector') t (c) 
-- RETURNS: <x>2</x><y>3</y>
--          <x>5</x><y>7</y>

SELECT c.value('x[1]', 'int'), c.value('y[1]', 'int') FROM @Vector.nodes('vectors/vector') t (c) -- requires a singleton
-- RETURNS:	2	3
--        	5	7
go

-- ============================================================================
-- parse a comma separated list
DECLARE @list VARCHAR(MAX) = 'Olivia, Emma, Charlotte'

DECLARE @xml XML = '<x>' + REPLACE(@list, ',', '</x><x>') + '</x>'

SELECT LTRIM(c.value('.', 'varchar(max)')) FROM @xml.nodes('x') t (c)
--Olivia
--Emma
--Charlotte
go

-- ============================================================================
-- parse a comma separated list
DECLARE @list VARCHAR(MAX) = 'Olivia, Emma, Charlotte'

SELECT LTRIM(t2.c.value('.', 'varchar(max)')) 
FROM (VALUES (CAST('<x>' + REPLACE(@list, ',', '</x><x>') + '</x>' AS XML))) t1 (c)
CROSS APPLY t1.c.nodes('x') t2 (c)
--Olivia
--Emma
--Charlotte
go

-- ============================================================================
-- get tag name
declare @xml xml = '<x><a>1</a><b>2</b><c>3</c></x>'

select c.value('fn:local-name(.)', 'char(1)') from @xml.nodes('x/*') t (c)
--a
--b
--c
go

-- ============================================================================
-- get attribute value
declare @xml xml = '<x><a type="11">1</a><a type="22">2</a><a type="33">3</a></x>'

select c.value('@type', 'int') from @xml.nodes('x/a') t (c)
--11
--22
--33
go
