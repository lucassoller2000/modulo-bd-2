create view ex1 as(SELECT IDPRODUTO, NOME FROM PRODUTO WHERE IDPRODUTO NOT IN 
(SELECT IT.IDPRODUTO FROM PEDIDOITEM IT INNER JOIN PEDIDO P ON P.IDPEDIDO = IT.IDPEDIDO WHERE P.DATAPEDIDO > ADD_MONTHS(sysdate, -6)));

CREATE view ex as (SELECT IT.IDPRODUTO FROM PEDIDOITEM IT INNER JOIN PEDIDO P ON P.IDPEDIDO = IT.IDPEDIDO WHERE P.DATAPEDIDO > ADD_MONTHS(sysdate, -6));

update produto set situacao = 'I' where IDPRODUTO IN (select IDPRODUTO from ex1);

select vw.IDPEDIDO, VW.QUANTIDADE, vw.RANKING FROM (SELECT P.IDPEDIDO, QUANTIDADE, RANK() OVER (ORDER BY QUANTIDADE desc) AS RANKING FROM PEDIDOITEM IP INNER JOIN PEDIDO P ON P.IDPEDIDO =  IP.IDPEDIDO) vw ;



