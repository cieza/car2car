/* -*- Mode: C++; c-file-style: "gnu"; indent-tabs-mode:nil -*- */
/*
 * Copyright (c) 2012 University of California, Los Angeles
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation;
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * Author:
 */

#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/applications-module.h"
#include "ns3/wifi-module.h"
#include "ns3/mobility-module.h"
#include "ns3/internet-module.h"
#include "ns3/ndnSIM-module.h"

#include <boost/shared_ptr.hpp>
#include <boost/make_shared.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/tokenizer.hpp>

#include "ndn-v2v-net-device-face.h"
#include "v2v-tracer.h"
//#include "ndn-app-delay-tracer.h"

using namespace ns3;
using namespace boost;
using namespace std;

NS_LOG_COMPONENT_DEFINE ("Experiment");

//////////////////////////////////////////////////////////////////////////
//
// Modificado em dezembro 2014 por Elise G Cieza
//
//////////////////////////////////////////////////////////////////////////


Ptr<ndn::NetDeviceFace>
V2vNetDeviceFaceCallback (Ptr<Node> node, Ptr<ndn::L3Protocol> ndn, Ptr<NetDevice> device)
{
    NS_LOG_DEBUG ("Creating ndn::V2vNetDeviceFace on node " << node->GetId ());
    
    Ptr<ndn::NetDeviceFace> face = CreateObject<ndn::V2vNetDeviceFace> (node, device);
    ndn->AddFace (face);
    //cout << node->GetId () << ": added NetDeviceFace as face #" << *face << "\n";
    // NS_LOG_LOGIC ("Node " << node->GetId () << ": added NetDeviceFace as face #" << *face);
    
    return face;
}

int
main (int argc, char *argv[])
{
    
    // disable fragmentation
    Config::SetDefault ("ns3::WifiRemoteStationManager::FragmentationThreshold", StringValue ("2200"));
    Config::SetDefault ("ns3::WifiRemoteStationManager::RtsCtsThreshold", StringValue ("2200"));
    Config::SetDefault ("ns3::WifiRemoteStationManager::NonUnicastMode", StringValue ("OfdmRate24Mbps"));
    
    // vanet hacks to CcnxL3Protocol
    Config::SetDefault ("ns3::ndn::V2vNetDeviceFace::MaxDelay", StringValue ("2ms"));
    Config::SetDefault ("ns3::ndn::V2vNetDeviceFace::MaxDelayLowPriority", StringValue ("2ms"));
    Config::SetDefault ("ns3::ndn::V2vNetDeviceFace::MaxDistance", StringValue ("150"));
    
    // !!! very important parameter !!!
    // Should keep PIT entry to prevent duplicate interests from re-propagating
    Config::SetDefault ("ns3::ndn::Pit::PitEntryPruningTimout", StringValue ("1s"));
    
    uint32_t numberOfCars = 49;
    
    if(argc > 1)
    {
        numberOfCars = atoi(argv[1]);
    }
    
    CommandLine cmd;
    cmd.Parse (argc,argv);
    
    //--------------------------------------------------------------------------
    //
    // Configurando Wifi
    //
    //--------------------------------------------------------------------------
    
    WifiHelper wifi = WifiHelper::Default ();
    // wifi.SetRemoteStationManager ("ns3::AarfWifiManager");
    wifi.SetStandard (WIFI_PHY_STANDARD_80211a);
    wifi.SetRemoteStationManager ("ns3::ConstantRateWifiManager",
                                  "DataMode", StringValue ("OfdmRate24Mbps"));
    
    YansWifiChannelHelper wifiChannel;// = YansWifiChannelHelper::Default ();
    wifiChannel.SetPropagationDelay ("ns3::ConstantSpeedPropagationDelayModel");
    wifiChannel.AddPropagationLoss ("ns3::ThreeLogDistancePropagationLossModel");
    wifiChannel.AddPropagationLoss ("ns3::NakagamiPropagationLossModel");
    
    //YansWifiPhy wifiPhy = YansWifiPhy::Default();
    YansWifiPhyHelper wifiPhyHelper = YansWifiPhyHelper::Default ();
    wifiPhyHelper.SetChannel (wifiChannel.Create ());
    wifiPhyHelper.Set("TxPowerStart", DoubleValue(5));
    wifiPhyHelper.Set("TxPowerEnd", DoubleValue(5));
    
    
    NqosWifiMacHelper wifiMac = NqosWifiMacHelper::Default ();
    wifiMac.SetType("ns3::AdhocWifiMac");
    
    //--------------------------------------------------------------------------
    //
    // Mobilidade
    //
    //--------------------------------------------------------------------------
    
    //*************  teste
    /*Ptr<ListPositionAllocator> positionAlloc = CreateObject<ListPositionAllocator> ();
     positionAlloc->Add (Vector (0.0, 20.0, 0.0));
     positionAlloc->Add (Vector (115.0, 20.0, 0.0)); //antes 137
     positionAlloc->Add (Vector (230.0, 20.0, 0.0));
     
     MobilityHelper mobility;
     mobility.SetPositionAllocator (positionAlloc);
     
     mobility.SetMobilityModel ("ns3::ConstantPositionMobilityModel");*/
    //*************  fim teste
    
    //area baseada no shopping mall at millenia de 103.866 metros quadrados, estacionamento (320X360) --> mudou para (525 X 700) dar gordura (600 X 800)
    
    MobilityHelper mobility;
    // setup the grid itself: objects are layed out
    // started from (0,0) with 7 objects per row,
    // the x interval between each object is 45,7 meters
    // and the y interval between each object is 51,4 meters
    mobility.SetPositionAllocator ("ns3::GridPositionAllocator",
                                   "MinX", DoubleValue (0.0),
                                   "MinY", DoubleValue (0.0),
                                   "DeltaX", DoubleValue (75.0),
                                   "DeltaY", DoubleValue (100.0),
                                   "GridWidth", UintegerValue (7),
                                   "LayoutType", StringValue ("RowFirst"));
    
    //sem mobilidade - GRID 7 x 7 CONSTANT POSITION
    
    mobility.SetMobilityModel ("ns3::ConstantPositionMobilityModel");
    
    //com mobilidade - GRID 7 X 7 VEICULAR
    
    /*mobility.SetMobilityModel ("ns3::Vehicular2dMobilityModel",
                               "Bounds", StringValue ("-10|590|-10|790"),
                               "Time", StringValue ("10s"),
                               "Mode", StringValue ("Time"),
                               "Direction", StringValue ("ns3::UniformRandomVariable[Min=0.0|Max=6.283184]"),
                               "Speed", StringValue ("ns3::UniformRandomVariable[Min=2.0|Max=4.0]"));*/
    
    
    //--------------------------------------------------------------------------
    //
    // Configurando nós
    //
    //--------------------------------------------------------------------------
    
    // Create nodes
    NodeContainer nodes;
    nodes.Create (numberOfCars);
    
    // 1. Install Mobility model
    mobility.Install (nodes);
    
    // 2. Install Wifi
    NetDeviceContainer wifiNetDevices = wifi.Install (wifiPhyHelper, wifiMac, nodes);
    
    // 3. Install NDN stack
    NS_LOG_INFO ("Installing NDN stack");
    ndn::StackHelper ndnHelper;
    ndnHelper.AddNetDeviceFaceCreateCallback (WifiNetDevice::GetTypeId (), MakeCallback (V2vNetDeviceFaceCallback));
    ndnHelper.SetForwardingStrategy ("ns3::ndn::fw::V2v");
    ndnHelper.SetContentStore ("ns3::ndn::cs::Lru", "MaxSize", "500");// size=#seqnumbers
    //ndnHelper.SetContentStore ("ns3::ndn::cs::Nocache");
    ndnHelper.SetDefaultRoutes(true);
    ndnHelper.Install(nodes);
    
    // 4. Set up applications
    NS_LOG_INFO ("Installing Applications");
    
    std::string prefix = "/prefix";
    
    // Consumer will request /prefix/0, /prefix/1, ...
    
    ndn::AppHelper consumerHelper ("ns3::ndn::ConsumerCbr");
    consumerHelper.SetPrefix (prefix);
    double taxa_envio_leg = 20.0;
    consumerHelper.SetAttribute ("Frequency", DoubleValue (taxa_envio_leg));
    cout<<"Taxa_envio_leg: "<<taxa_envio_leg<<"\n";
    //consumerHelper.SetAttribute ("Randomize", StringValue ("uniform"))
    consumerHelper.SetAttribute ("MaxSeq", IntegerValue (500));
    
    std::map<int, int> nodes_map;
    
    bool encontrou = false;
    int num_rand = 0;
    srand(time(0));
    
    while(!encontrou)
    {
        num_rand = rand() % numberOfCars;
        if (nodes_map.find(num_rand) == nodes_map.end())
        {
            nodes_map[num_rand] = 1;
            encontrou = true;
            consumerHelper.Install (nodes.Get (num_rand));
            cout<<"Consumidor: "<<num_rand<<"\n";
        }
    }
    
    encontrou = false;
    while(!encontrou)
    {
        num_rand = rand() % numberOfCars;
        if (nodes_map.find(num_rand) == nodes_map.end())
        {
            nodes_map[num_rand] = 1;
            encontrou = true;
            consumerHelper.Install (nodes.Get (num_rand));
            cout<<"Consumidor: "<<num_rand<<"\n";
        }
    }
    
    encontrou = false;
    while(!encontrou)
    {
        num_rand = rand() % numberOfCars;
        if (nodes_map.find(num_rand) == nodes_map.end())
        {
            nodes_map[num_rand] = 1;
            encontrou = true;
            consumerHelper.Install (nodes.Get (num_rand));
            cout<<"Consumidor: "<<num_rand<<"\n";
        }
    }
    
    encontrou = false;
    while(!encontrou)
    {
        num_rand = rand() % numberOfCars;
        if (nodes_map.find(num_rand) == nodes_map.end())
        {
            nodes_map[num_rand] = 1;
            encontrou = true;
            consumerHelper.Install (nodes.Get (num_rand));
            cout<<"Consumidor: "<<num_rand<<"\n";
        }
    }
    
    encontrou = false;
    while(!encontrou)
    {
        num_rand = rand() % numberOfCars;
        if (nodes_map.find(num_rand) == nodes_map.end())
        {
            nodes_map[num_rand] = 1;
            encontrou = true;
            consumerHelper.Install (nodes.Get (num_rand));
            cout<<"Consumidor: "<<num_rand<<"\n";
        }
    }
    
    //consumerHelper.Install (nodes.Get (2));
    //consumerHelper.Install (nodes.Get (3));
    //consumerHelper.Install (nodes.Get (6));
    //consumerHelper.Install (nodes.Get (9));
    //consumerHelper.Install (nodes.Get (12));
    
    // Producer will reply to all requests starting with /prefix
    
    ndn::AppHelper producerHelper ("ns3::ndn::Producer");
    producerHelper.SetPrefix (prefix);
    producerHelper.SetAttribute ("PayloadSize", StringValue("500"));
    //producerHelper.Install (nodes.Get (0));
    encontrou = false;
    while(!encontrou)
    {
        num_rand = rand() % numberOfCars;
        if (nodes_map.find(num_rand) == nodes_map.end())
        {
            nodes_map[num_rand] = 1;
            encontrou = true;
            producerHelper.Install (nodes.Get (num_rand));
            cout<<"Produtor: "<<num_rand<<"\n";
        }
    }
    
    // 5. Set up applications << nos atacantes
    /*NS_LOG_INFO ("Installing Applications - Malicious Nodes");
     
     std::string prefixAttack = "/polluted";
     
     // Consumer will request /polluted/0, /polluted/1, ...
     
     ndn::AppHelper consumerHelperAttack ("ns3::ndn::ConsumerCbr");
     consumerHelperAttack.SetPrefix (prefixAttack);
     consumerHelperAttack.SetAttribute ("Frequency", DoubleValue (20.0));
     consumerHelperAttack.Install (nodes.Get (3));//voltar para 5
     //consumerHelperAttack.Install (nodes.Get (10));
     //consumerHelperAttack.Install (nodes.Get (15));
     
     // Producer will reply to all requests starting with /polluted
     
     ndn::AppHelper producerHelperAttack ("ns3::ndn::Producer");
     producerHelperAttack.SetPrefix (prefixAttack);
     producerHelperAttack.SetAttribute ("PayloadSize", StringValue("1024"));
     producerHelperAttack.Install (nodes.Get (1));*/
    
    //--------------------------------------------------------------------------
    //
    // Simulacao
    //
    //--------------------------------------------------------------------------
    
    
    //boost::tuple< boost::shared_ptr<std::ostream>, std::list<boost::shared_ptr<ndn::V2vTracer> > >
    //tracing = ndn::V2vTracer::InstallAll ("results/car-pusher2.txt");
    
    std::string tracer("resultados/ndn-with-cache-no-mob/experimento_");
    tracer = tracer.append(argv[2]);
    tracer = tracer.append("/rodada_");
    tracer = tracer.append(argv[3]);
    tracer = tracer.append("/trace.txt");
    
    //cout << tracer << "\n";
    
    boost::tuple< boost::shared_ptr<std::ostream>, std::list<boost::shared_ptr<ndn::V2vTracer> > >
    tracing = ndn::V2vTracer::InstallAll (tracer);
        
    Simulator::Stop (Seconds (100.0));
    
    NS_LOG_INFO ("Starting");
    
    Simulator::Run ();
    
    NS_LOG_INFO ("Done");
    
    Simulator::Destroy ();
    
    return 0;
}
