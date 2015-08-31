#!/usr/bin/perl

use File::Path;
use POSIX;

$diretorio = "/home/elise/car2car/resultados";

#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-no-cache-no-mob-pollution/experimento_1";
#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-with-cache-no-mob/experimento_1";
#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-with-cache-no-mob-pollution/experimento_1";

#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-no-cache-no-mob/experimento_2";
#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-no-cache-no-mob-pollution/experimento_2";
#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-with-cache-no-mob/experimento_2";
#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-with-cache-no-mob-pollution/experimento_2";

#@ic_99 = ();
#$ic_99[0] = 63.66;
#$ic_99[1] = 9.925;
#$ic_99[2] = 5.841;
#$ic_99[3] = 4.604;
#$ic_99[4] = 4.032;
#$ic_99[5] = 3.707;
#$ic_99[6] = 3.499;
#$ic_99[7] = 3.355;
#$ic_99[8] = 3.250;
#$ic_99[9] = 3.169;
#$ic_99[10] = 3.106;
#$ic_99[11] = 3.055;
#$ic_99[12] = 3.012;
#$ic_99[13] = 2.977;
#$ic_99[14] = 2.947;
#$ic_99[15] = 2.921;
#$ic_99[16] = 2.898;
#$ic_99[17] = 2.878;
#$ic_99[18] = 2.861;
#$ic_99[19] = 2.845;
#$ic_99[20] = 2.831;


@ic_95 = ();
$ic_95[0] = 12.706;
$ic_95[1] = 4.303;
$ic_95[2] = 3.182;
$ic_95[3] = 2.776;
$ic_95[4] = 2.571;
$ic_95[5] = 2.447;
$ic_95[6] = 2.365;
$ic_95[7] = 2.306;
$ic_95[8] = 2.262;
$ic_95[9] = 2.228;
$ic_95[10] = 2.201;
$ic_95[11] = 2.179;
$ic_95[12] = 2.160;
$ic_95[13] = 2.145;
$ic_95[14] = 2.131;
$ic_95[15] = 2.120;
$ic_95[16] = 2.110;
$ic_95[17] = 2.101;
$ic_95[18] = 2.093;
$ic_95[19] = 2.086;
$ic_95[20] = 2.080;

sub media{
    my $n = scalar(@_);
    my $sum = 0;
    
    foreach $item (@_){
        $sum += $item;
    }
    my $media = 0;
    if($n != 0){
        $media = $sum / $n;
    }
    else
    {
        my $media = 0;
    }
    return $media;
}

sub desvPad{
    my $media = media(@_);
    my $sum = 0;
    my $n = scalar(@_);
    my $i = 0;
    while($i < $n)
    {
        $item = @_[$i];
        $sum = (POSIX::pow( $item - $media, 2 )) + $sum;
        $i = $i + 1;
    }
    my $desvPad = $sum/($n - 1);
    return $desvPad;
}

sub variancia{
    my $desvio = desvPad(@_);
    return sqrt($desvio);
}

sub confidence{
    my $n = scalar(@_);
    my $graus_de_liberdade = $n - 1;
    my $value = $ic_95[$graus_de_liberdade];
    my $confidenceValue = $value * (variancia(@_)/sqrt($n));
    return $confidenceValue;
}


$n = $ARGV[0];
$n_final  = $ARGV[1];

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

@scenarios_coluna_0 = ();
$scenarios_coluna_0[0] = "X";

@scenarios_coluna_1 = ();
$scenarios_coluna_1[0] = "Y";

@scenarios_txentrega_relativa = ();
$scenarios_txentrega_relativa[0] = ["Politica","NaoProativo","ProAtivo"];

@scenarios_ocupacao_maliciosa = ();
$scenarios_ocupacao_maliciosa[0] = ["Politica","NaoProativo","ProAtivo"];

@scenarios_delay = ();
$scenarios_delay[0] = ["Politica","NaoProativo","ProAtivo"];

@scenarios_delay_disp = ();
$scenarios_delay_disp[0] = ["Politica","NaoProativo","ProAtivo"];

@scenarios_last_delay = ();
$scenarios_last_delay[0] = ["Politica","NaoProativo","ProAtivo"];

@scenarios_hit = ();
$scenarios_hit[0] = ["Politica","NaoProativo","ProAtivo"];

@scenarios_miss = ();
$scenarios_miss[0] = ["Politica","NaoProativo","ProAtivo"];

@scenarios_hit_rate = ();
$scenarios_hit_rate[0] = ["Politica","NaoProativo","ProAtivo"];

@scenarios_hopcount_medio = ();
$scenarios_hopcount_medio[0] = ["Politica","NaoProativo","ProAtivo"];

@scenarios_hopcount_maximo = ();
$scenarios_hopcount_maximo[0] = ["Politica","NaoProativo","ProAtivo"];

@scenarios_hopcount_minimo = ();
$scenarios_hopcount_minimo[0] = ["Politica","NaoProativo","ProAtivo"];


@scenarios_interesses_enviados = ();
$scenarios_interesses_enviados[0] = ["Politica","NaoProativo","ProAtivo"];

@scenarios_interesses_satisfeitos = ();
$scenarios_interesses_satisfeitos[0] = ["Politica","NaoProativo","ProAtivo"];

@scenarios_interesses_enviados_satisfeitos = ();
$scenarios_interesses_enviados_satisfeitos[0] = ["Politica","NaoProativo_Enviados","ProAtivo_Enviados","NaoProativo_Satisfeitos","ProAtivo_Satisfeitos"];







mkpath("/home/elise/car2car/graficos_variacoes_atacantes/");

$k = 2;
# percorre cada subdiretorio, ou seja, percorre os cenarios
foreach $dir_scenario(@lista)
{
    
    # verifica se nao eh um dos dois diretorios sempre encontrados nas pastas do Unix
    if($dir_scenario ne "." and $dir_scenario ne ".." and (index($dir_scenario, "pollution") != -1))
    {
        # lista de diretorios de experimentos com dois diretorios, um do nao proativo e
        #@experimentos_dirs = ();
        
        # cria o nome do diretorio que contem experimento nao proativo, onde n eh impar
        #$dir_exp_n = $diretorio."/".$dir_scenario."/experimento_".$n;
        
        # cria o nome do diretorio que contem experimento proativo
        #$dir_exp_n_1 = $diretorio."/".$dir_scenario."/experimento_".($n+1);
        
        # em 0 se encontra o nao proativo e em 1 se encontra o proativo
        #$experimentos_dirs[0] = $dir_exp_n;
        #$experimentos_dirs[1] = $dir_exp_n_1;
        
        
        $i = 1;
        @experimentos = ();
        @experimentos_ocupacao_maliciosa = ();
        @experimentos_delays = ();
        @experimentos_delays_disp = ();
        @experimentos_last_delays = ();
        @experimentos_cache_miss = ();
        @experimentos_cache_hit = ();
        @experimentos_cache_hit_rate = ();
        
        @experimentos_txentrega_relativa = ();
        
        @experimentos_hopcount_medio = ();
        @experimentos_hopcount_maximo = ();
        @experimentos_hopcount_minimo = ();
        
        
        @experimentos_interesses_enviados_satisfeito = ();
        
        @experimentos_interesses_enviados = ();
        @experimentos_interesses_satisfeito = ();
        
        #lista de erros
        @erro_experimentos = ();
        @erro_experimentos_ocupacao_maliciosa = ();
        @erro_experimentos_delays = ();
        @erro_experimentos_last_delays = ();
        @erro_experimentos_cache_miss = ();
        @erro_experimentos_cache_hit = ();
        @erro_experimentos_cache_hit_rate = ();
        
        @erro_experimentos_txentrega_relativa = ();
        
        @erro_experimentos_hopcount_medio = ();
        @erro_experimentos_hopcount_maximo = ();
        @erro_experimentos_hopcount_minimo = ();
        
        
        @erro_experimentos_interesses_enviados_satisfeito = ();
        
        @erro_experimentos_interesses_enviados = ();
        @erro_experimentos_interesses_satisfeito = ();
        
        # percorre sobre os diretorios enquanto não termina
        #foreach $experimento_dir(@experimentos_dirs)
        $y = $n;
        while($y <= $n_final)
        {
            $experimento_dir = $diretorio."/".$dir_scenario."/experimento_".$y;
            opendir(diretorio_experimento, $experimento_dir);
            
            # lista com nome de todas as rodadas
            @lista_experimento = readdir(diretorio_experimento);
            
            closedir(diretorio_experimento);
            
            $sum_packet_raw = 0;
            $sum_satisfied_packet_raw = 0;
            $count = 0;
            $satisfeitos = 0;
            $interesses = 0;
            
            #guarda uma lista mostrando a taxa de entrega (interesses satisfeitos/interesses_totais) para cada rodada
            @lista_taxa_entrega_rodadas = ();
            #guarda uma lista mostrando os interesses realizados para cada rodada
            @lista_interesses_rodadas = ();
            #guarda uma lista mostrando os interesses satisfeitos para cada rodada
            @lista_satisfeitos_rodadas = ();
            #guarda uma lista mostrando a taxa de ocupação maliciosa para cada rodada
            @lista_ocupacao_maliciosa_rodadas = ();
            #guarda uma lista mostrando a soma dos delays para cada rodada
            @lista_soma_delays_rodadas = ();
            #guarda uma lista mostrando a soma dos delays (com a nova conta só vendo o ultimo interesse) para cada rodada
            @lista_soma_last_delays_rodadas = ();
            #guarda uma lista mostrando a soma da media misse para cada rodada
            @lista_miss_rodadas = ();
            #guarda uma lista mostrando a soma da media hits para cada rodada
            @lista_hit_rodadas = ();
            #guarda uma lista mostrando a taxa hit/total para cada rodada
            @lista_hit_rate_rodadas = ();
            #guarda uma lista mostrando o hopcount medio para cada rodada
            @lista_hopcount_medio_rodadas = ();
            
            
            $soma_num_poluidos = 0;
            $soma_num_total = 0;
            
            $soma_delays = 0;
            
            $soma_last_delays = 0;
            
            $soma_hopcount = 0;
            $num_hopcount = 0;
            $hopcount_maximo = undef;
            $hopcount_minimo = undef;
            
            $soma_cache_miss = 0;
            $soma_cache_hit = 0;
            
            $max_seq = 0;
            
            $num_atacantes = 0;
            $taxa_envio_atac = 0;
            $leu_o_primeiro_arquivo = 0;
            
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
                    
                    # HashMap que vai guardar o tempo de atraso para satisfazer o interesse pela primeira vez, pelo ultimo interesse, a chave corresponde ao ID do no
                    %last_delays = ();
                    
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
                    #print("$file_name\n");
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
                        
                        if($linha[0] eq "atraso_pi")
                        {
                            $last_delays{$linha[1]} = $linha[2];
                        }
                        
                        if($linha[0] eq "hit")
                        {
                            $hits{$linha[1]} = $linha[2];
                            $misses{$linha[1]} = $linha[3];
                        }
                        
                        if($leu_o_primeiro_arquivo == 0)
                        {
                            if($linha[0] eq "Atacante:")
                            {
                                $num_atacantes = $num_atacantes + 1;
                            }
                            if($linha[0] eq "Taxa_envio_atac:")
                            {
                                $taxa_envio_atac = $linha[1];
                            }
                        }
                        
                        
                        
                    }
                    close ARK;
                    $leu_o_primeiro_arquivo = 1;
                    
                    $aux_satisfeitos = 0;
                    # lista valores guarda todos os valores do HashMap de satisfeitos, a chave (ID do no) nao interessa para o calculo da taxa de entrega
                    @valores = values %taxas_entrega_satisfeitos;
                    
                    # satisfeitos guarda a soma de todos o interesses satisfeitos para as n rodadas, para todos os nos, ao percorrer a lista de valores
                    foreach(@valores)
                    {
                        $satisfeitos = $satisfeitos + $_;
                        $aux_satisfeitos = $aux_satisfeitos + $_;
                    }
                    
                    $aux_interesses = 0;
                    
                    @valores = values %taxas_entrega_interesses;
                    
                    # interesses guarda a soma de todos o interesses enviados para as n rodadas, para todos os nos, ao percorrer a lista de valores
                    foreach(@valores)
                    {
                        $interesses = $interesses + $_;
                        $aux_interesses = $aux_interesses + $_;
                    }
                    
                    $lista_satisfeitos_rodadas[$count] = $aux_satisfeitos;
                    if($aux_interesses != 0)
                    {
                        $lista_taxa_entrega_rodadas[$count] = $aux_satisfeitos/$aux_interesses;
                    }
                    else
                    {
                        $lista_taxa_entrega_rodadas[$count] = 0;
                    }
                    $lista_interesses_rodadas[$count] = $aux_interesses;
                    
                    
                    $aux_soma_num_poluidos = 0;
                    
                    @valores = values %ocupacao_num_poluidos;
                    
                    # soma_num_poluidos guarda a soma de todos os conteudos poluidos em cache para as n rodadas, para todos os nos, ao percorrer a lista de valores
                    foreach(@valores)
                    {
                        $soma_num_poluidos = $soma_num_poluidos + $_;
                        $aux_soma_num_poluidos = $aux_soma_num_poluidos + $_;
                    }
                    
                    $aux_soma_num_total = 0;
                    
                    @valores = values %ocupacao_num_total;
                    
                    # soma_num_total guarda a soma de todos os conteudos em cache para as n rodadas, para todos os nos, ao percorrer a lista de valores
                    foreach(@valores)
                    {
                        $soma_num_total = $soma_num_total + $_;
                        $aux_soma_num_total = $aux_soma_num_total + $_;
                    }
                    
                    if($aux_soma_num_total != 0)
                    {
                        $lista_ocupacao_maliciosa_rodadas[$count] = $aux_soma_num_poluidos/$aux_soma_num_total;
                    }
                    else
                    {
                        $lista_ocupacao_maliciosa_rodadas[$count]= 0;
                    }
                    
                    
                    
                    @valores = values %delays;
                    
                    # soma o total de atraso e faz a media desse total, em seguida
                    $soma_aux = 0;
                    foreach(@valores)
                    {
                        $soma_aux = $soma_aux + $_;
                    }
                    
                    if($soma_aux != 0){
                        $soma_aux = $soma_aux/(scalar @valores);
                        $soma_delays = $soma_delays + $soma_aux;
                    }
                    else{
                        $soma_delays = 0;
                    }
                    
                    #$lista_soma_delays_rodadas[$count] = $soma_delays;
                    $lista_soma_delays_rodadas[$count] = $soma_aux;
                    
                    
                    #soma total de atrso e faz a media desse total em seguida
                    @valores = values %last_delays;
                    $soma_aux = 0;
                    foreach(@valores)
                    {
                        $soma_aux = $soma_aux + $_;
                    }
                    
                    if($soma_aux != 0){
                        $soma_aux = $soma_aux/(scalar @valores);
                        $soma_last_delays = $soma_last_delays + $soma_aux;
                    }
                    else{
                        $soma_last_delays = 0;
                    }
                    
                    #$lista_soma_last_delays_rodadas[$count] = $soma_last_delays;
                    $lista_soma_last_delays_rodadas[$count] = $soma_aux;
                    
                    
                    $aux_cache_miss = 0;
                    
                    @valores = values %misses;
                    
                    # soma_cache_miss guarda a soma de misses para as n rodadas, para todos os nos, ao percorrer a lista de valores
                    foreach(@valores)
                    {
                        $soma_cache_miss = $soma_cache_miss + $_;
                        $aux_cache_miss = $aux_cache_miss + $_;
                    }
                    
                    $lista_miss_rodadas[$count] = $aux_cache_miss;
                    
                    
                    $aux_cache_hit = 0;
                    
                    @valores = values %hits;
                    
                    # soma_cache_hit guarda a soma de hits para as n rodadas, para todos os nos, ao percorrer a lista de valores
                    foreach(@valores)
                    {
                        $soma_cache_hit = $soma_cache_hit + $_;
                        $aux_cache_hit = $aux_cache_hit + $_;
                    }
                    
                    $lista_hit_rodadas[$count] = $aux_cache_hit;
                    
                    $lista_hit_rate_rodadas[$count] = $aux_cache_hit/($aux_cache_hit+$aux_cache_miss);
                    
                    $aux_soma_hopcount = 0;
                    #soma total dos hopcounts e do numero de vezes que um interesse foi atendido para fazer uma media
                    @valores = values %hopcount_soma;
                    foreach(@valores)
                    {
                        $soma_hopcount = $soma_hopcount + $_;
                        $aux_soma_hopcount = $aux_soma_hopcount + $_;
                    }
                    
                    $aux_hopcount_numero = 0;
                    @valores = values %hopcount_numero;
                    foreach(@valores)
                    {
                        $num_hopcount = $num_hopcount + $_;
                        $aux_hopcount_numero = $aux_hopcount_numero + $_;
                    }
                    
                    
                    $lista_hopcount_medio_rodadas[$count] = $aux_soma_hopcount/$aux_hopcount_numero;
                    
                    
                    # conta o numero de rodadas
                    $count = $count + 1;
                }
                
            }
            
            # faz a media das n rodadas
            
            if($interesses != 0){
                $taxa_entrega = $satisfeitos/$interesses;
                $experimentos[$i] = $taxa_entrega;
                #aqui verifica o erro da taxa de entrega.
                #$lista_satisfeitos_rodadas[$count]
                $erro = confidence(@lista_taxa_entrega_rodadas);
                #print("Erro taxa entrega: $erro_taxa_entrega\n");
                $erro_experimentos[$i] = $erro;
                
            }
            else{
                $taxa_entrega = 0;
                $experimentos[$i] = $taxa_entrega;
                
            }
            
            $max_seq = 500 * (scalar keys %taxas_entrega_satisfeitos) * $count;
            if($max_seq != 0){
                $taxa_entrega_relativa = $satisfeitos/$max_seq;
                $experimentos_txentrega_relativa[$i] = $taxa_entrega_relativa;
                
                #aqui verifica o erro da taxa de entrega relativa
                $index = 0;
                @lista_taxa_entrega_relativa_rodadas = ();
                while($index < $count)
                {
                    $lista_taxa_entrega_relativa_rodadas[$index] = $lista_satisfeitos_rodadas[$index]/(500 * (scalar keys %taxas_entrega_satisfeitos));
                    $index = $index+1;
                }
                $erro = confidence(@lista_taxa_entrega_relativa_rodadas);
                $erro_experimentos_txentrega_relativa[$i] = $erro;
            }
            else{
                $taxa_entrega_relativa = 0;
                $experimentos_txentrega_relativa[$i] = $taxa_entrega_relativa;
                
            }
            
            if($soma_num_total != 0){
                $media_ocupacao_maliciosa = $soma_num_poluidos/$soma_num_total;
                $experimentos_ocupacao_maliciosa[$i] = $media_ocupacao_maliciosa;
                #aqui colocar o erro da taxa de ocupacao maliciosa
                
                $erro = confidence(@lista_ocupacao_maliciosa_rodadas);
                $erro_experimentos_ocupacao_maliciosa[$i] = $erro;
            }
            else{
                $media_ocupacao_maliciosa = 0;
                $experimentos_ocupacao_maliciosa[$i] = $media_ocupacao_maliciosa;
            }
            
            if($count != 0){
                $media_delay = $soma_delays/$count;
                $experimentos_delays[$i] = $media_delay;
                #aqui colocar o erro dos delays medios
                $erro = confidence(@lista_soma_delays_rodadas);
                #colocar aqui dados para criar o grafico atraso_disp
                @aux_atraso_disp_valores = ();
                foreach(@lista_soma_delays_rodadas)
                {
                    push (@aux_atraso_disp_valores, $_);
                    print("Delay: $_ \n");
                }
                $experimentos_delays_disp[$i] = [@aux_atraso_disp_valores];
                #fim do atraso_disp
                
                $erro_experimentos_delays[$i] = $erro;
            }
            else{
                $media_delay = 0;
                $experimentos_delays[$i] = $media_delay;
            }
            
            if($count != 0){
                $media_last_delay = $soma_last_delays/$count;
                $experimentos_last_delays[$i] = $media_last_delay;
                #aqui colocar o erro dos delays médios
                $erro = confidence(@lista_soma_last_delays_rodadas);
                $erro_experimentos_last_delays[$i] = $erro;
            }
            else{
                $media_last_delay = 0;
                $experimentos_last_delays[$i] = $media_last_delay;
            }
            
            if($soma_cache_miss != 0){
                $media_cache_miss = $soma_cache_miss/$count;
                $experimentos_cache_miss[$i] = $media_cache_miss;
                #aqui colocar o erro do cache miss
                $erro = confidence(@lista_miss_rodadas);
                $erro_experimentos_cache_miss[$i] = $erro;
            }
            else{
                $media_cache_miss = 0;
                $experimentos_cache_miss[$i] = $media_cache_miss;
            }
            
            if($soma_cache_hit != 0){
                $media_cache_hit = $soma_cache_hit/$count;
                $experimentos_cache_hit[$i] = $media_cache_hit;
                $experimentos_cache_hit_rate[$i] = $media_cache_hit/($media_cache_hit + $experimentos_cache_miss[$i]);
                #erro cache hi
                $erro = confidence(@lista_hit_rodadas);
                $erro_experimentos_cache_hit[$i] = $erro;
                $erro = confidence(@lista_hit_rate_rodadas);
                $erro_experimentos_cache_hit_rate[$i] = $erro;
            }
            else{
                $media_cache_hit = 0;
                $experimentos_cache_hit[$i] = $media_cache_hit;
            }
            
            if($num_hopcount != 0){
                $experimentos_hopcount_medio[$i] = $soma_hopcount/$num_hopcount;
                #erro
                $erro = confidence(@lista_hopcount_medio_rodadas);
                $erro_experimentos_hopcount_medio[$i] = $erro;
            }
            else{
                $experimentos_hopcount_medio[$i] = 0;
            }
            $experimentos_hopcount_maximo[$i] = $hopcount_maximo;
            $experimentos_hopcount_minimo[$i] = $hopcount_minimo;
            
            $erro_experimentos_hopcount_maximo[$i] = 0;
            $erro_experimentos_hopcount_minimo[$i] = 0;
            
            if($count != 0){
                $intereses_realizados = $interesses/$count;
                $intereses_satisfeitos = $satisfeitos/$count;
                
            }
            else{
                $intereses_realizados = 0;
                $intereses_satisfeitos = 0;
            }
            
            $experimentos_interesses_enviados_satisfeito[$i] = $intereses_realizados;
            
            $experimentos_interesses_enviados[$i] = $intereses_realizados;
            
            $experimentos_interesses_enviados_satisfeito[$i+2] = $intereses_satisfeitos;
            
            $experimentos_interesses_satisfeito[$i] = $intereses_satisfeitos;
            
            #erro
            $erro = confidence(@lista_interesses_rodadas);
            $erro_experimentos_interesses_enviados_satisfeito[$i] = $erro;
            $erro_experimentos_interesses_enviados[$i] = $erro;
            $erro = confidence(@lista_satisfeitos_rodadas);
            $erro_experimentos_interesses_enviados_satisfeito[$i+2] = $erro;
            $erro_experimentos_interesses_satisfeito[$i] = $erro;
            
            
            $scenarios_coluna_0[$i] = $num_atacantes;
            print("Numero de attacantes: $num_atacantes\n");
            
            $scenarios_coluna_1[$i] = $taxa_envio_atac;
            print("Taxa_envio_atac: $taxa_envio_atac\n");
            
            
            
            
            # identifica o numero do experimento
            $i = $i + 1;
            $y = $y + 2;
            
        }
        
        # serve para preencher com o nome do cenario correspondente
        $experimentos[0] = $dir_scenario;
        # guarda os resultados para o cenario k
        $scenarios[$k] = [@experimentos];
        
        
        
        #erro
        $erro_experimentos[0] = "erro_".$dir_scenario;
        $scenarios[$k+1] = [@erro_experimentos];
        
        $scenarios[0] = [@scenarios_coluna_0];
        $scenarios[1] = [@scenarios_coluna_1];
        
        
        $experimentos_txentrega_relativa[0] = $dir_scenario;
        $scenarios_txentrega_relativa[$k] = [@experimentos_txentrega_relativa];
        #erro
        $erro_erro_experimentos_txentrega_relativa[0] = "erro_".$dir_scenario;
        $scenarios_txentrega_relativa[$k+1] = [@erro_experimentos_txentrega_relativa];
        
        $scenarios_txentrega_relativa[0] = [@scenarios_coluna_0];
        $scenarios_txentrega_relativa[1] = [@scenarios_coluna_1];
        
        $experimentos_ocupacao_maliciosa[0] = $dir_scenario;
        $scenarios_ocupacao_maliciosa[$k] = [@experimentos_ocupacao_maliciosa];
        #erro
        $erro_experimentos_ocupacao_maliciosa[0] = "erro_".$dir_scenario;
        $scenarios_ocupacao_maliciosa[$k+1] = [@erro_experimentos_ocupacao_maliciosa];
        
        $scenarios_ocupacao_maliciosa[0] = [@scenarios_coluna_0];
        $scenarios_ocupacao_maliciosa[1] = [@scenarios_coluna_1];
        
        $experimentos_delays[0] = $dir_scenario;
        $scenarios_delay[$k] = [@experimentos_delays];
        #erro
        $erro_experimentos_delays[0] = "erro_".$dir_scenario;
        $scenarios_delay[$k+1] = [@erro_experimentos_delays];        
        
        $scenarios_delay[0] = [@scenarios_coluna_0];
        $scenarios_delay[1] = [@scenarios_coluna_1];
        
        
        
        #o grafico de atraso disp
        $experimentos_delays_disp[0] = $dir_scenario;
        $scenarios_delay_disp[$k] = [@experimentos_delays_disp];
        #erro
        $scenarios_delay_disp[$k+1] = [@erro_experimentos_delays];
        
        
        $scenarios_delay_disp[0] = [@scenarios_coluna_0];
        $scenarios_delay_disp[1] = [@scenarios_coluna_1];
        
        
        
        
        $experimentos_last_delays[0] = $dir_scenario;
        $scenarios_last_delay[$k] = [@experimentos_last_delays];
        #erro
        $erro_experimentos_last_delays[0] = "erro_".$dir_scenario;
        $scenarios_last_delay[$k+1] = [@erro_experimentos_last_delays];
        
        $scenarios_last_delay[0] = [@scenarios_coluna_0];
        $scenarios_last_delay[1] = [@scenarios_coluna_1];
        
        $experimentos_cache_miss[0] = $dir_scenario;
        $scenarios_miss[$k] = [@experimentos_cache_miss];
        #erro
        $erro_experimentos_cache_miss[0] = "erro_".$dir_scenario;
        $scenarios_miss[$k+1] = [@erro_experimentos_cache_miss];
        
        $scenarios_miss[0] = [@scenarios_coluna_0];
        $scenarios_miss[1] = [@scenarios_coluna_1];
        
        
        $experimentos_cache_hit[0] = $dir_scenario;
        $scenarios_hit[$k] = [@experimentos_cache_hit];
        #erro
        $erro_experimentos_cache_hit[0] = "erro_".$dir_scenario;
        $scenarios_hit[$k+1] = [@erro_experimentos_cache_hit];
        
        $scenarios_hit[0] = [@scenarios_coluna_0];
        $scenarios_hit[1] = [@scenarios_coluna_1];
        
        
        $experimentos_cache_hit_rate[0] = $dir_scenario;
        $scenarios_hit_rate[$k] = [@experimentos_cache_hit_rate];
        #erro
        $erro_experimentos_cache_hit_rate[0] = "erro_".$dir_scenario;
        $scenarios_hit_rate[$k+1] = [@erro_experimentos_cache_hit_rate];
        
        $scenarios_hit_rate[0] = [@scenarios_coluna_0];
        $scenarios_hit_rate[1] = [@scenarios_coluna_1];
        
        
        $experimentos_hopcount_medio[0] = $dir_scenario;
        $scenarios_hopcount_medio[$k] = [@experimentos_hopcount_medio];
        #erro
        $erro_experimentos_hopcount_medio[0] = "erro_".$dir_scenario;
        $scenarios_hopcount_medio[$k+1] = [@erro_experimentos_hopcount_medio];
        
        
        $scenarios_hopcount_medio[0] = [@scenarios_coluna_0];
        $scenarios_hopcount_medio[1] = [@scenarios_coluna_1];
        
        
        $experimentos_hopcount_maximo[0] = $dir_scenario;
        $scenarios_hopcount_maximo[$k] = [@experimentos_hopcount_maximo];
        #erro
        $erro_experimentos_hopcount_maximo[0] = "erro_".$dir_scenario;
        $scenarios_hopcount_maximo[$k+1] = [@erro_experimentos_hopcount_maximo];
        
        $scenarios_hopcount_maximo[0] = [@scenarios_coluna_0];
        $scenarios_hopcount_maximo[1] = [@scenarios_coluna_1];
        
        $experimentos_hopcount_minimo[0] = $dir_scenario;
        $scenarios_hopcount_minimo[$k] = [@experimentos_hopcount_minimo];
        #erro
        $erro_experimentos_hopcount_minimo[0] = "erro_".$dir_scenario;
        $scenarios_hopcount_minimo[$k+1] = [@erro_experimentos_hopcount_minimo];
        
        $scenarios_hopcount_minimo[0] = [@scenarios_coluna_0];
        $scenarios_hopcount_minimo[1] = [@scenarios_coluna_1];
        
        $experimentos_interesses_enviados_satisfeito[0] = $dir_scenario;
        $scenarios_interesses_enviados_satisfeitos[$k] = [@experimentos_interesses_enviados_satisfeito];
        #erro
        $erro_experimentos_interesses_enviados_satisfeito[0] = "erro_".$dir_scenario;
        $scenarios_interesses_enviados_satisfeitos[$k+1] = [@erro_experimentos_interesses_enviados_satisfeito];
        
        $experimentos_interesses_enviados[0] = $dir_scenario;
        $scenarios_interesses_enviados[$k] = [@experimentos_interesses_enviados];
        #erro
        $erro_experimentos_interesses_enviados[0] = "erro_".$dir_scenario;
        $scenarios_interesses_enviados[$k+1] = [@erro_experimentos_interesses_enviados];
        
        $experimentos_interesses_satisfeito[0] = $dir_scenario;
        $scenarios_interesses_satisfeitos[$k] = [@experimentos_interesses_satisfeito];
        #erro
        $erro_experimentos_interesses_satisfeito[0] = "erro_".$dir_scenario;
        $scenarios_interesses_satisfeitos[$k+1] = [@erro_experimentos_interesses_satisfeito];
        
        
        
        $scenarios_interesses_enviados_satisfeitos[0] = [@scenarios_coluna_0];
        $scenarios_interesses_enviados_satisfeitos[1] = [@scenarios_coluna_1];
        
        
        $k = $k + 2;
    }
    
    
}

$total = $i;

$file_name = "/home/elise/car2car/graficos_variacoes_atacantes/txentrega.txt";
open ARK, ">".$file_name;
select ARK;
$i = 0;
while($i < $total)
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

$file_name = "/home/elise/car2car/graficos_variacoes_atacantes/txentrega_relativa.txt";
open ARK, ">".$file_name;
select ARK;
$i = 0;
while($i < $total)
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
$file_name = "/home/elise/car2car/graficos_variacoes_atacantes/ocupacao.txt";
open ARK, ">".$file_name;
select ARK;
$i = 0;
while($i < $total)
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


$file_name = "/home/elise/car2car/graficos_variacoes_atacantes/atraso.txt";
open ARK, ">".$file_name;
select ARK;
$i = 0;
while($i < $total)
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


$file_name = "/home/elise/car2car/graficos_variacoes_atacantes/atraso_disp.txt";
open ARK, ">".$file_name;
select ARK;
$i = 0;
while($i < $total)
{
    
    #$number_of_delays = scalar($scenarios_delay_disp[2][$i]);
    if($i == 0)
    {
        $j = 0;
        while($j < $k)
        {
            if($j < 2)
            {
                print("$scenarios_delay_disp[$j][$i]      \t");
                $j = $j + 1;
            }
            else
            {
                #@lista_aux = $scenarios_delay_disp[$j][$i];
                print("$scenarios_delay_disp[$j][$i]      \t");
                $j = $j + 2;
             }
        }
        print("\n");
    }
    else
    {
        $list_reference = $scenarios_delay_disp[2][$i];
        @list_aux = @$list_reference;
        $number_of_delays = @list_aux;
        
        #$number_of_delays = 20;
        $l = 0;
        while($l < $number_of_delays)
        {
            $j = 0;
            while($j < $k)
            {
                if($j < 2)
                {
                    print("$scenarios_delay_disp[$j][$i]      \t");
                    $j = $j + 1;
                }
                else
                {
                    #@lista_aux = $scenarios_delay_disp[$j][$i];
                    print("$scenarios_delay_disp[$j][$i][$l]      \t");
                    $j = $j + 2;
                }
            }
            print("\n");
            $l = $l + 1;
        
        }
    }
    
    $i = $i + 1;
}


close ARK;


$file_name = "/home/elise/car2car/graficos_variacoes_atacantes/atraso_pi.txt";
open ARK, ">".$file_name;
select ARK;
$i = 0;
while($i < $total)
{
    $j = 0;
    while($j < $k)
    {
        print("$scenarios_last_delay[$j][$i]      \t");
        $j = $j + 1;
    }
    print("\n");
    $i = $i + 1;
}


close ARK;

$file_name = "/home/elise/car2car/graficos_variacoes_atacantes/cache_hit.txt";
open ARK, ">".$file_name;
select ARK;
$i = 0;
while($i < $total)
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

$file_name = "/home/elise/car2car/graficos_variacoes_atacantes/cache_miss.txt";
open ARK, ">".$file_name;
select ARK;
$i = 0;
while($i < $total)
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

$file_name = "/home/elise/car2car/graficos_variacoes_atacantes/cache_hitRATE.txt";
open ARK, ">".$file_name;
select ARK;
$i = 0;
while($i < $total)
{
    $j = 0;
    while($j < $k)
    {
        print("$scenarios_hit_rate[$j][$i]      \t");
        $j = $j + 1;
    }
    print("\n");
    $i = $i + 1;
}


close ARK;


$file_name = "/home/elise/car2car/graficos_variacoes_atacantes/hopcount_medio.txt";
open ARK, ">".$file_name;
select ARK;
$i = 0;
while($i < $total)
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


$file_name = "/home/elise/car2car/graficos_variacoes_atacantes/hopcount_maximo.txt";
open ARK, ">".$file_name;
select ARK;
$i = 0;
while($i < $total)
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


$file_name = "/home/elise/car2car/graficos_variacoes_atacantes/hopcount_minimo.txt";
open ARK, ">".$file_name;
select ARK;
$i = 0;
while($i < $total)
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





$file_name = "/home/elise/car2car/graficos_variacoes_atacantes/interesses_enviados.txt";
open ARK, ">".$file_name;
select ARK;
$i = 0;
while($i < $total)
{
    $j = 0;
    while($j < $k)
    {
        print("$scenarios_interesses_enviados[$j][$i]      \t");
        $j = $j + 1;
    }
    print("\n");
    $i = $i + 1;
}


close ARK;



$file_name = "/home/elise/car2car/graficos_variacoes_atacantes/interesses_satisfeito.txt";
open ARK, ">".$file_name;
select ARK;
$i = 0;
while($i < $total)
{
    $j = 0;
    while($j < $k)
    {
        print("$scenarios_interesses_satisfeitos[$j][$i]      \t");
        $j = $j + 1;
    }
    print("\n");
    $i = $i + 1;
}


close ARK;
