#!/usr/bin/perl

use File::Path;

$diretorio = "/home/elise/car2car/resultados";




$n = $ARGV[0];

#########################
opendir(diretorio, $diretorio);
# lista que contem todos os sub-diretorios do diretorio passado na linha 3
@lista = readdir(diretorio);
closedir(diretorio);

$count = 0;



$file_nos_name = "/home/elise/car2car/graficos_linha_interesses/";

$k = 1;
# percorre cada subdiretorio, ou seja, percorre os cenarios
foreach $dir_scenario(@lista)
{
    
    # verifica se nao eh um dos dois diretorios sempre encontrados nas pastas do Unix
    if($dir_scenario ne "." and $dir_scenario ne "..")
    {
        # lista de diretorios de experimentos com dois diretorios, um do nao proativo e
        @experimentos_dirs = ();
        
        # cria o nome do diretorio que contem experimento nao proativo, onde n eh impar
        $dir_exp_n = $diretorio."/".$dir_scenario."/experimento_".$n;
        
        # cria o nome do diretorio que contem experimento proativo
        $dir_exp_n_1 = $diretorio."/".$dir_scenario."/experimento_".($n+1);
        
        # em 0 se encontra o nao proativo e em 1 se encontra o proativo
        $experimentos_dirs[0] = $dir_exp_n;
        $experimentos_dirs[1] = $dir_exp_n_1;
        
        
        $i = 1;

        
        
        # percorre sobre os diretorios dos experimentos nao proativo e proativo
        foreach $experimento_dir(@experimentos_dirs)
        {
            
            opendir(diretorio_experimento, $experimento_dir);
            
            # lista com nome de todas as rodadas
            @lista_experimento = readdir(diretorio_experimento);
            
            closedir(diretorio_experimento);
            
            
            
            # iterando sobre todos os diretorios de rodadas
            foreach $dir_exp(@lista_experimento)
            {
                
                # verifica se a pasta eh valida
                if($dir_exp ne "." and $dir_exp ne "..")
                {
                    
                    # file_name guarda o caminho ate o arquivo saida.txt de uma determinada rodada
                    $file_name = $experimento_dir."/".$dir_exp."/saida.txt";
                    
                    
                    $dir = $file_nos_name.$dir_scenario."/experimento_".$i."/".$dir_exp;
                    mkpath($dir);
                    
                    # HashMap que vai guardar o numero de interesses satisfeitos onde a chave corresponde ao ID do no
                    %taxas_entrega_satisfeitos = ();
                    
                    # HashMap que vai guardar o numero de interesses enviados onde a chave corresponde ao ID do no
                    %taxas_entrega_interesses = ();
                    
                    $interesses_totais = 0;
                    $interesses_satisfeitos = 0;
                    
                    $file_aux_ark_name = $file_nos_name.$dir_scenario."/experimento_".$i."/".$dir_exp."/grafico_linha_interesses.txt";
                    open ARK2, ">".$file_aux_ark_name;
                    
                    # abre arquivo saida.txt para ler
                    open ARK, $file_name;
                    foreach(<ARK>)
                    {
                        # lista com o conteudo da linha corrente de saida.txt
                        @linha = split(/\s+/);
                        
                        # se a primeira palavra da lista for "Taxa_Entrega_Absoluta" entao atualiza HashMap com a ultima informacao para aquela chave
                        if($linha[0] eq "Taxa_Entrega_Absoluta")
                        {
                            
                            $taxas_entrega_satisfeitos{$linha[2]} = $linha[4];
                            $taxas_entrega_interesses{$linha[2]} = $linha[6];
                            
                            
                            $satisfeitos = 0;
                            # lista valores guarda todos os valores do HashMap de satisfeitos, a chave (ID do no) nao interessa para o calculo da taxa de entrega
                            @valores = values %taxas_entrega_satisfeitos;
                            # satisfeitos guarda a soma de todos o interesses satisfeitos para as n rodadas, para todos os nos, ao percorrer a lista de valores
                            foreach(@valores)
                            {
                                $satisfeitos = $satisfeitos + $_;
                            }
                    
                            $interesses = 0;   
                            @valores = values %taxas_entrega_interesses;
                            # interesses guarda a soma de todos o interesses enviados para as n rodadas, para todos os nos, ao percorrer a lista de valores
                            foreach(@valores)
                            {
                                $interesses = $interesses + $_;
                            }

                            #print("File name: $file_aux_ark_name\n");
                            select ARK2;
                            
                            print($linha[8]."   ".$interesses."   ".$satisfeitos."\n");
                            
                            select STDOUT;
                            
                            
                        }
                       
                        
                    }
                    close ARK;
                    close ARK2;
                    
                   #conta o numero de rodadas
                    $count = $count + 1;
                }
                
            }
            

            # identifica se eh nao proativo (i=1) ou se eh proativo (i=2)
            $i = $i + 1;
            
        }
        
        $k = $k + 1;
    }
    
    
}
