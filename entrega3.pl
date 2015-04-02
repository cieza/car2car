#!/usr/bin/perl

$diretorio = "/home/elise/car2car/resultados";

#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-no-cache-no-mob-pollution/experimento_1";
#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-with-cache-no-mob/experimento_1";
#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-with-cache-no-mob-pollution/experimento_1";

#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-no-cache-no-mob/experimento_2";
#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-no-cache-no-mob-pollution/experimento_2";
#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-with-cache-no-mob/experimento_2";
#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-with-cache-no-mob-pollution/experimento_2";


$n = $ARGV[0];

#########################
opendir(diretorio, $diretorio);
# lista que contem todos os sub-diretorios do diretorio passado na linha 3
@lista = readdir(diretorio);
closedir(diretorio);


#$sum_packets = 0;
$sum_packet_raw = 0;
#$sum_out_packets = 0;
$sum_satisfied_packet_raw = 0;
$count = 0;
@scenarios = ();
$scenarios[0] = ["Politica","NaoProativo","ProAtivo"];

@scenarios_ocupacao_maliciosa = ();
$scenarios_ocupacao_maliciosa[0] = ["Politica","NaoProativo","ProAtivo"];

@scenarios_delay = ();
$scenarios_delay[0] = ["Politica","NaoProativo","ProAtivo"];

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
        @experimentos = ();
        @experimentos_ocupacao_maliciosa = ();
        @experimentos_delays = ();
        
        # percorre sobre os diretorios dos experimentos nao proativo e proativo
        foreach $experimento_dir(@experimentos_dirs)
        {
            
            opendir(diretorio_experimento, $experimento_dir);
            
            # lista com nome de todas as rodadas
            @lista_experimento = readdir(diretorio_experimento);
            
            closedir(diretorio_experimento);
        
            $sum_packet_raw = 0;
            $sum_satisfied_packet_raw = 0;
            $count = 0;
            $satisfeitos = 0;
            $interesses = 0;
            
            $soma_num_poluidos = 0;
            $soma_num_total = 0;
            
            $soma_delays = 0;
            
            # iterando sobre todos os diretorios de rodadas
            foreach $dir_exp(@lista_experimento)
            {
        
                # verifica se a pasta eh valida
                if($dir_exp ne "." and $dir_exp ne "..")
                {
        
                    # file_name guarda o caminho ate o arquivo saida.txt de uma determinada rodada
                    $file_name = $experimento_dir."/".$dir_exp."/saida.txt";
                    #$packets = 0;
                    $ininterest_packet_raw = 0;
                    #$out_packets = 0;
                    $insatisfiedinterest_packet_raw = 0;
                    
                    # HashMap que vai guardar o numero de interesses satisfeitos onde a chave corresponde ao ID do no
                    %taxas_entrega_satisfeitos = ();
                    
                    # HashMap que vai guardar o numero de interesses enviados onde a chave corresponde ao ID do no
                    %taxas_entrega_interesses = ();
                    
                    # HashMap que vai guardar o numero de conteudos com prefixo /polluted no CS onde a chave corresponde ao ID do no
                    %ocupacao_num_poluidos = ();
                    
                    # HashMap que vai guardar o numero de conteudos totais no CS onde a chave corresponde ao ID do no
                    %ocupacao_num_total = ();
                    
                    # HashMap que vai guardar o tempo de atraso para satisfazer o interesse pela primeira vez, a chave corresponde ao ID do no
                    %delays = ();
                    
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
                            
                        }
                        if($linha[0] eq "Ocupacao_Maliciosa")
                        {
                            $ocupacao_num_poluidos{$linha[2]} = $linha[4];
                            $ocupacao_num_total{$linha[2]} = $linha[6];
                        }
                        if($linha[0] eq "Atraso")
                        {
                            $delays{$linha[2]} = $linha[4];
                        }

                    }
                    close ARK;
                    
                    # lista valores guarda todos os valores do HashMap de satisfeitos, a chave (ID do no) nao interessa para o calculo da taxa de entrega
                    @valores = values %taxas_entrega_satisfeitos;
                    
                    # satisfeitos guarda a soma de todos o interesses satisfeitos para as n rodadas, para todos os nos, ao percorrer a lista de valores
                    foreach(@valores)
                    {
                        $satisfeitos = $satisfeitos + $_;
                    }
                    
                    @valores = values %taxas_entrega_interesses;
                    
                    # interesses guarda a soma de todos o interesses enviados para as n rodadas, para todos os nos, ao percorrer a lista de valores
                    foreach(@valores)
                    {
                        $interesses = $interesses + $_;
                    }
                    
                    @valores = values %ocupacao_num_poluidos;
                    
                    # soma_num_poluidos guarda a soma de todos os conteudos poluidos em cache para as n rodadas, para todos os nos, ao percorrer a lista de valores
                    foreach(@valores)
                    {
                        $soma_num_poluidos = $soma_num_poluidos + $_;
                    }
                    
                    @valores = values %ocupacao_num_total;
                    
                    # soma_num_total guarda a soma de todos os conteudos em cache para as n rodadas, para todos os nos, ao percorrer a lista de valores
                    foreach(@valores)
                    {
                        $soma_num_total = $soma_num_total + $_;
                    }
                    
                    @valores = values %delays;
                    
                    # soma o total de atraso e faz a media desse total, em seguida
                    $soma_aux = 0;
                    foreach(@valores)
                    {
                        $soma_aux = $soma_aux + $_;
                    }
                    $soma_aux = $soma_aux/(scalar @valores);
                    $soma_delays = $soma_delays + $soma_aux;
        
                    # conta o numero de rodadas
                    $count = $count + 1;
                }

        
            }
            
            # faz a media das n rodadas
            
            $taxa_entrega = $satisfeitos/$interesses;
            $experimentos[$i] = $taxa_entrega;
            
            
            $media_ocupacao_maliciosa = $soma_num_poluidos/$soma_num_total;
            $experimentos_ocupacao_maliciosa[$i] = $media_ocupacao_maliciosa;
            
            
            $media_delay = $soma_delays/$count;
            $experimentos_delays[$i] = $media_delay;
            
            # identifica se eh nao proativo (i=1) ou se eh proativo (i=2)
            $i = $i + 1;
        
        }
        
        # serve para preencher com o nome do cenario correspondente
        $experimentos[0] = $dir_scenario;
        # guarda os resultados para o cenario k
        $scenarios[$k] = [@experimentos];
        
        $experimentos_ocupacao_maliciosa[0] = $dir_scenario;
        $scenarios_ocupacao_maliciosa[$k] = [@experimentos_ocupacao_maliciosa];
        
        $experimentos_delays[0] = $dir_scenario;
        $scenarios_delay[$k] = [@experimentos_delays];
        
        
        $k = $k + 1;
    }
    
    
}


$file_name = "/home/elise/car2car/txentrega.txt";
open ARK, ">".$file_name;
select ARK;
$i = 0;
while($i < 3)
{
    $j = 0;
    while($j < $k)
    {
        print("$scenarios[$j][$i]      \t");
        $j = $j + 1;
    }
    print("\n");
    $i = $i + 1;
}


close ARK;
#medias
#$x =  $sum_packets/$count;
$file_name = "/home/elise/car2car/ocupacao.txt";
open ARK, ">".$file_name;
select ARK;
$i = 0;
while($i < 3)
{
    $j = 0;
    while($j < $k)
    {
        print("$scenarios_ocupacao_maliciosa[$j][$i]      \t");
        $j = $j + 1;
    }
    print("\n");
    $i = $i + 1;
}


close ARK;


$file_name = "/home/elise/car2car/atraso.txt";
open ARK, ">".$file_name;
select ARK;
$i = 0;
while($i < 3)
{
    $j = 0;
    while($j < $k)
    {
        print("$scenarios_delay[$j][$i]      \t");
        $j = $j + 1;
    }
    print("\n");
    $i = $i + 1;
}


close ARK;
