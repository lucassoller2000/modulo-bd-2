-- ex1
declare
    cursor C_ListaCi is
        select ci.nome as nomeCidade, c.nome as nomeCliente
        from cidade ci
        inner join cliente c
        on c.idcidade = ci.idcidade
        where ci.nome in 
        (select nome 
        from cidade 
        group by nome 
        having (count(1)>1)) 
        order by ci.Nome;
  begin
  for reg in C_ListaCi loop
    DBMS_OUTPUT.PUT_LINE('Nome da cidade: ' || reg.nomeCidade || ' - Nome do cliente: ' || reg.nomeCliente);
  end loop;
end;

--ex 2
declare
    cursor C_Lista(identificador in number) is
        select (precounitario * quantidade) as total, idproduto
        from pedidoitem
        where idpedido = identificador;
identificador number := 1;
  begin
  for reg in C_Lista(identificador) loop
    DBMS_OUTPUT.PUT_LINE('ID do produto: ' || reg.idproduto || ' - Valor total R$:' || reg.total);
  end loop;
end;

--ex 3
create view sempedido as(SELECT IDPRODUTO, NOME FROM PRODUTO WHERE IDPRODUTO NOT IN 
(SELECT IT.IDPRODUTO FROM PEDIDOITEM IT INNER JOIN PEDIDO P ON P.IDPEDIDO = IT.IDPEDIDO WHERE P.DATAPEDIDO > ADD_MONTHS(sysdate, -6)));

DECLARE
    V_QTD NUMBER;
BEGIN
    UPDATE Produto
    SET situacao = 'I'
    WHERE idproduto in (select idProduto from sempedido);
    IF SQL%FOUND THEN
        V_QTD := SQL%ROWCOUNT;
        DBMS_OUTPUT.PUT_LINE('ATUALIZOU ' || V_QTD || ' REGISTROS');
    COMMIT;
    END IF;
END;

--ex 4
declare
    cursor C_Lista_Ex_4(identificador in number, anoEMes in varchar) is
        select pi.quantidade as quantidadeProduto, pr.nome as nomeProduto from pedido p 
        inner join pedidoitem pi on pi.idpedido = p.idpedido 
        inner join produto pr on pr.idproduto = pi.idproduto
        where pi.idproduto = identificador and p.datapedido like '%'||anoEMes;
identificador number := 1;
anoEMes varchar(5) := '03/15';
  begin
  for reg in C_Lista_Ex_4(identificador, anoEMes) loop
    DBMS_OUTPUT.PUT_LINE('Nome do produto: ' || reg.nomeProduto || ' - Quantidade: ' || reg.quantidadeProduto);
  end loop;
end;





