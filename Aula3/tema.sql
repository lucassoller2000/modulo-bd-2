  CREATE OR REPLACE PACKAGE PCK_CIDADE as
  
  procedure ajusta_cidade_cliente(pNome in varchar2, pUF in varchar2, pMenorIDCidade in integer);
  procedure exclui_cidades_duplicadas(pNome in varchar2, pUF in varchar2, pMenorIDCidade in integer);
  procedure elimina_duplicadas;
end PCK_CIDADE;

/

CREATE OR REPLACE PACKAGE BODY PCK_CIDADE as
  
  procedure ajusta_cidade_cliente(pNome in varchar2, 
                                  pUF in varchar2, 
                                  pMenorIDCidade in integer) as
  begin
      update Cliente set idcidade = null
      where idcidade != pMenorIDCidade
      and pNome in 
      (SELECT Nome FROM Cidade
      GROUP BY Nome, UF HAVING COUNT(*)> 1);     
  end ajusta_cidade_cliente;

  procedure exclui_cidades_duplicadas(pNome in varchar2, 
                                      pUF in varchar2, 
                                      pMenorIDCidade in integer) as
  begin
     delete from Cidade 
     where idCidade != pMenorIdCidade
     and pNome in
     (SELECT Nome FROM Cidade
     GROUP BY Nome, UF HAVING COUNT(*)> 1); 
  end exclui_cidades_duplicadas;

  procedure elimina_duplicadas as
  cursor lista_duplicada is
  SELECT Nome, UF ,MIN(IDCidade) MenorId
  ,COUNT(1) Contador FROM Cidade
  GROUP BY Nome ,UF HAVING COUNT(*)> 1;
  begin
      for reg in lista_duplicada loop
            ajusta_cidade_cliente(reg.Nome, reg.UF, reg.MenorId);
            exclui_cidades_duplicadas(reg.Nome, reg.UF, reg.MenorId);
      end loop;
  end elimina_duplicadas;
end PCK_CIDADE;

/