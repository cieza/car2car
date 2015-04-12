#!/usr/bin/perl

use File::Path;

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

@scenarios_txentrega_relativa = ();
$scenarios_txentrega_relativa[0] = ["Politica","NaoProativo","ProAtivo"];

@scenarios_ocupacao_maliciosa = ();
$scenarios_ocupacao_maliciosa[0] = ["Politica","NaoProativo","ProAtivo"];

@scenarios_delay = ();
$scenarios_delay[0] = ["Politica","NaoProativo","ProAtivo"];

@scenarios_hit = ();
$scenarios_hit[0] = ["Politica","NaoProativo","ProAtivo"];

@scenarios_miss = ();
$scenarios_miss[0] = ["Politica","NaoProativo","ProAtivo"];

@scenarios_hopcount_medio = ();
$scenarios_hopcount_medio[0] = ["Politica","NaoProativo","ProAtivo"];

@scenarios_hopcount_maximo = ();
$scenarios_hopcount_maximo[0] = ["Politica","NaoProativo","ProAtivo"];

@scenarios_hopcount_minimo = ();
$scenarios_hopcount_minimo[0] = ["Politica","NaoProativo","ProAtivo"];


@scenarios_interesses_enviados_satisfeitos = ();
$scenarios_interesses_enviados_satisfeitos[0] = ["Politica","NaoProativo_Enviados","ProAtivo_Enviados","NaoProativo_Satisfeitos","ProAtivo_Satisfeitos"];


mkpath("/home/elise/car2car/graficos_barra/");

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
        @experimentos_cache_miss = ();
        @experimentos_cache_hit = ();
        
        @experimentos_txentrega_relativa = ();
        
        @experimentos_hopcount_medio = ();
        @experimentos_hopcount_maximo = ();
        @experimentos_hopcount_minimo = ();
        
        
        @experimentos_interesses_enviados_satisfeito = ();
        
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
            
            $soma_hopcount = 0;
            $num_hopcount = 0;
            $hopcount_maximo = undef;
            $hopcount_minimo = undef;
            
            $soma_cache_miss = 0;
            $soma_cache_hit = 0;
            
            $max_seq = 0;
            
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
                    
                    # HashMap que vai guardar total de hits, a chave corresponde ao ID do no
                    %hits = ();
                    
                    # HashMap que vai guardar total de misses, a chave corresponde ao ID do no
                    %misses = ();
                    
                    # HashMap que vai guardar a soma de hopcounts para atender os interesses do no, a chave corresponde ao ID do no
                    %hopcount_soma = ();
                    
                    # HashMap que vai guardar o numero de hopcounts para atender os interesses do no, a chave corresponde ao ID do no
                    %hopcount_numero = ();
                    
                    # HashMap que vai guardar o maior hopcount para atender os interesses do no, a chave corresponde ao ID do no
                    %hopcount_maximo = ();
                    
                    # HashMap que vai guardar o menor hopcount para atender os interesses do no, a chave corresponde ao ID do no
                    %hopcount_minimo = ();
                    
                    
                    
                    # abre arquivo saida.txt para ler
                    open ARK, $file_name;
                    foreach(<ARK>)
                    {
                        # lista com o conteudo da linha corrente de saida.txt
                        @linha = split(/\s+/);
                        
                        # se a primeira palavra da lista for "Taxa_Entrega_Absoluta" entao atualiza HashMap com a ultima informacao para aquela chave
                        if($linha[0] eq "txentrega")
                        {
                            $taxas_entrega_satisfeitos{$linha[1]} = $linha[2];
                            $taxas_entrega_interesses{$linha[1]} = $linha[3];
                            
                            
                            if($linha[7] ne undef)
                            {
                                
                                if($hopcount_soma{$linha[1]} eq undef)
                                {
                                    $hopcount_soma{$linha[1]} = 0;
                                }
                                if($hopcount_numero{$linha[1]} eq undef)
                                {
                                    $hopcount_numero{$linha[1]} = 0;
                                }
                                if($hopcount_maximo{$linha[1]} eq undef)
                                {
                                    $hopcount_maximo{$linha[1]} = $linha[7];
                                }
                                if($hopcount_minimo{$linha[1]} eq undef)
                                {
                                    $hopcount_minimo{$linha[1]} = $linha[7];
                                }
                                
                                
                                $hopcount_soma{$linha[1]} = $hopcount_soma{$linha[1]} + $linha[7];
                                $hopcount_numero{$linha[1]} = $hopcount_numero{$linha[1]} + 1;
                                if($hopcount_maximo{$linha[1]} < $linha[7] )
                                {
                                    $hopcount_maximo{$linha[1]} = $linha[7];
                                }
                                if($hopcount_minimo{$linha[1]} > $linha[7])
                                {
                                    $hopcount_minimo{$linha[1]} = $linha[7];
                                }
                                
                                
                                
                                if($hopcount_maximo eq undef)
                                {
                                    $hopcount_maximo = $linha[7];
                                }
                                if($hopcount_minimo eq undef)
                                {
                                    $hopcount_minimo = $linha[7];
                                }
                                if($hopcount_maximo < $linha[7])
                                {
                                    $hopcount_maximo = $linha[7];
                                }
                                if($hopcount_minimo > $linha[7])
                                {
                                    $hopcount_minimo = $linha[7];
                                }
                                
                                
                            }
                        }
                        if($linha[0] eq "ocup_maliciosa")
                        {
                            $ocupacao_num_poluidos{$linha[1]} = $linha[2];
                            $ocupacao_num_total{$linha[1]} = $linha[3];
                        }
                        if($linha[0] eq "atraso")
                        {
                            $delays{$linha[1]} = $linha[2];
                        }
                        if($linha[0] eq "hit")
                        {
                            $hits{$linha[1]} = $linha[2];
                            $misses{$linha[1]} = $linha[3];
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
                    
                    @valores = values %misses;
                    
                    # soma_cache_miss guarda a soma de misses para as n rodadas, para todos os nos, ao percorrer a lista de valores
                    foreach(@valores)
                    {
                        $soma_cache_miss = $soma_cache_miss + $_;
                    }
                    
                    @valores = values %hits;
                    
                    # soma_cache_hit guarda a soma de hits para as n rodadas, para todos os nos, ao percorrer a lista de valores
                    foreach(@valores)
                    {
                        $soma_cache_hit = $soma_cache_hit + $_;
                    }
                    
                    #soma total dos hopcounts e do numero de vezes que um interesse foi atendido para fazer uma media
                    @valores = values %hopcount_soma;
                    foreach(@valores)
                    {
                        $soma_hopcount = $soma_hopcount + $_;
                    }
                    
                    @valores = values %hopcount_numero;
                    foreach(@valores)
                    {
                        $num_hopcount = $num_hopcount + $_;
                    }
                    
                    
                    # conta o numero de rodadas
                    $count = $count + 1;
                }
                
            }
            
            # faz a media das n rodadas
            
            if($interesses != 0){
                $taxa_entrega = $satisfeitos/$interesses;
                $experimentos[$i] = $taxa_entrega;
            }
            else{
                $taxa_entrega = 0;
                $experimentos[$i] = $taxa_entrega;
            }
            
            $max_seq = 500 * (scalar keys %taxas_entrega_satisfeitos) * $count;
            if($max_seq != 0){
                $taxa_entrega_relativa = $satisfeitos/$max_seq;
                $experimentos_txentrega_relativa[$i] = $taxa_entrega_relativa;
            }
            else{
                $taxa_entrega_relativa = 0;
                $experimentos_txentrega_relativa[$i] = $taxa_entrega_relativa;
            }
            
            if($soma_num_total != 0){
                $media_ocupacao_maliciosa = $soma_num_poluidos/$soma_num_total;
                $experimentos_ocupacao_maliciosa[$i] = $media_ocupacao_maliciosa;
            }
            else{
                $media_ocupacao_maliciosa = 0;
                $experimentos_ocupacao_maliciosa[$i] = $media_ocupacao_maliciosa;
            }
            
            if($count != 0){
                $media_delay = $soma_delays/$count;
                $experimentos_delays[$i] = $media_delay;
            }
            else{
                $media_delay = 0;
                $experimentos_delays[$i] = $media_delay;
            }
            
            if($soma_cache_miss != 0){
                $media_cache_miss = $soma_cache_miss/$count;
                $experimentos_cache_miss[$i] = $media_cache_miss;
            }
            else{
                $media_cache_miss = 0;
                $experimentos_cache_miss[$i] = $media_cache_miss;
            }
            
            if($soma_cache_hit != 0){
                $media_cache_hit = $soma_cache_hit/$count;
                $experimentos_cache_hit[$i] = $media_cache_hit;
            }
            else{
                $media_cache_hit = 0;
                $experimentos_cache_hit[$i] = $media_cache_hit;
            }
            
            if($num_hopcount != 0){
                $experimentos_hopcount_medio[$i] = $soma_hopcount/$num_hopcount;
            }
            else{
                $experimentos_hopcount_medio[$i] = 0;
            }
            $experimentos_hopcount_maximo[$i] = $hopcount_maximo;
            $experimentos_hopcount_minimo[$i] = $hopcount_minimo;
            
            
            $intereses_realizados = $interesses/$count;
            $intereses_satisfeitos = $satisfeitos/$count;
            
            $experimentos_interesses_enviados_satisfeito[$i] = $intereses_realizados;
            $experimentos_interesses_enviados_satisfeito[$i+2] = $intereses_satisfeitos;
            
            
            # identifica se eh nao proativo (i=1) ou se eh proativo (i=2)
            $i = $i + 1;
            
        }
        
        # serve para preencher com o nome do cenario correspondente
        $experimentos[0] = $dir_scenario;
        # guarda os resultados para o cenario k
        $scenarios[$k] = [@experimentos];
        
        $experimentos_txentrega_relativa[0] = $dir_scenario;
        $scenarios_txentrega_relativa[$k] = [@experimentos_txentrega_relativa];
        
        $experimentos_ocupacao_maliciosa[0] = $dir_scenario;
        $scenarios_ocupacao_maliciosa[$k] = [@experimentos_ocupacao_maliciosa];
        
        $experimentos_delays[0] = $dir_scenario;
        $scenarios_delay[$k] = [@experimentos_delays];
        
        $experimentos_cache_miss[0] = $dir_scenario;
        $scenarios_miss[$k] = [@experimentos_cache_miss];
        
        $experimentos_cache_hit[0] = $dir_scenario;
        $scenarios_hit[$k] = [@experimentos_cache_hit];
        
        $experimentos_hopcount_medio[0] = $dir_scenario;
        $scenarios_hopcount_medio[$k] = [@experimentos_hopcount_medio];
        
        $experimentos_hopcount_maximo[0] = $dir_scenario;
        $scenarios_hopcount_maximo[$k] = [@experimentos_hopcount_maximo];
        
        $experimentos_hopcount_minimo[0] = $dir_scenario;
        $scenarios_hopcount_minimo[$k] = [@experimentos_hopcount_minimo];
        
        $experimentos_interesses_enviados_satisfeito[0] = $dir_scenario;
        $scenarios_interesses_enviados_satisfeitos[$k] = [@experimentos_interesses_enviados_satisfeito];
        
        
        $k = $k + 1;
    }
    
    
}


$file_name = "/home/elise/car2car/graficos_barra/txentrega.txt";
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

$file_name = "/home/elise/car2car/graficos_barra/txentrega_relativa.txt";
open ARK, ">".$file_name;
select ARK;
$i = 0;
while($i < 3)
{
    $j = 0;
    while($j < $k)
    {
        print("$scenarios_txentrega_relativa[$j][$i]      \t");
        $j = $j + 1;
    }
    print("\n");
    $i = $i + 1;
}


close ARK;

#medias
#$x =  $sum_packets/$count;
$file_name = "/home/elise/car2car/graficos_barra/ocupacao.txt";
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


$file_name = "/home/elise/car2car/graficos_barra/atraso.txt";
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

$file_name = "/home/elise/car2car/graficos_barra/cache_hit.txt";
open ARK, ">".$file_name;
select ARK;
$i = 0;
while($i < 3)
{
    $j = 0;
    while($j < $k)
    {
        print("$scenarios_hit[$j][$i]      \t");
        $j = $j + 1;
    }
    print("\n");
    $i = $i + 1;
}


close ARK;

$file_name = "/home/elise/car2car/graficos_barra/cache_miss.txt";
open ARK, ">".$file_name;
select ARK;
$i = 0;
while($i < 3)
{
    $j = 0;
    while($j < $k)
    {
        print("$scenarios_miss[$j][$i]      \t");
        $j = $j + 1;
    }
    print("\n");
    $i = $i + 1;
}


close ARK;

$file_name = "/home/elise/car2car/graficos_barra/cache_hitRATE.txt";
open ARK, ">".$file_name;
select ARK;
$i = 0;
while($i < 3)
{
    $j = 0;
    while($j < $k)
    {
        
        if($j != 0 && $i != 0)
        {
            $hit_rate = $scenarios_hit[$j][$i]/($scenarios_miss[$j][$i] + $scenarios_hit[$j][$i]);
            print("$hit_rate      \t");
        }
        else
        {
           print("$scenarios_miss[$j][$i]      \t");
        }
        $j = $j + 1;
    }
    print("\n");
    $i = $i + 1;
}


close ARK;


$file_name = "/home/elise/car2car/graficos_barra/hopcount_medio.txt";
open ARK, ">".$file_name;
select ARK;
$i = 0;
while($i < 3)
{
    $j = 0;
    while($j < $k)
    {
        print("$scenarios_hopcount_medio[$j][$i]      \t");
        $j = $j + 1;
    }
    print("\n");
    $i = $i + 1;
}


close ARK;


$file_name = "/home/elise/car2car/graficos_barra/hopcount_maximo.txt";
open ARK, ">".$file_name;
select ARK;
$i = 0;
while($i < 3)
{
    $j = 0;
    while($j < $k)
    {
        print("$scenarios_hopcount_maximo[$j][$i]      \t");
        $j = $j + 1;
    }
    print("\n");
    $i = $i + 1;
}


close ARK;


$file_name = "/home/elise/car2car/graficos_barra/hopcount_minimo.txt";
open ARK, ">".$file_name;
select ARK;
$i = 0;
while($i < 3)
{
    $j = 0;
    while($j < $k)
    {
        print("$scenarios_hopcount_minimo[$j][$i]      \t");
        $j = $j + 1;
    }
    print("\n");
    $i = $i + 1;
}


close ARK;


$file_name = "/home/elise/car2car/graficos_barra/interesses_enviados_satisfeito.txt";
open ARK, ">".$file_name;
select ARK;
$i = 0;
while($i < 5)
{
    $j = 0;
    while($j < $k)
    {
        print("$scenarios_interesses_enviados_satisfeitos[$j][$i]      \t");
        $j = $j + 1;
    }
    print("\n");
    $i = $i + 1;
}


close ARK;
