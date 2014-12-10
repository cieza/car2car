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
  Config::SetDefault ("ns3::ndn::V2vNetDeviceFace::MaxDelayLowPriority", StringValue ("5ms"));
  Config::SetDefault ("ns3::ndn::V2vNetDeviceFace::MaxDistance", StringValue ("150"));

  // !!! very important parameter !!!
  // Should keep PIT entry to prevent duplicate interests from re-propagating
  Config::SetDefault ("ns3::ndn::Pit::PitEntryPruningTimout", StringValue ("1s"));

  CommandLine cmd;

  uint32_t numberOfCars = 3;

  if(argc > 1)
  {
     numberOfCars = atoi(argv[1]);
     //cout<<"Numero: "<<atoi(argv[1])<<"\n";
     //cout<<"Primeiro parametro: "<<argv[0]<<"\n";
  }

  uint32_t run = 1;
  cmd.AddValue ("run", "Run", run);

  //string batches = "2s 1";
  //cmd.AddValue ("batches", "Consumer interest batches", batches);

  double distance = 10;
  cmd.AddValue ("distance", "Distance between cars (default 10 meters)", distance);

  double fixedDistance = -1;
  cmd.AddValue ("fixedDistance", "Length of the highway. Number of cars will be set as (fixedDistance / distance + 1). If not set, there are 1000 cars", fixedDistance);

  cmd.Parse (argc,argv);

  //uint32_t numberOfCars = 3;
  /*if (fixedDistance > 0)
    {
      numberOfCars = fixedDistance / distance + 1;
    }*/

  Config::SetGlobal ("RngRun", IntegerValue (run));

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
  
  //teste
  /*Ptr<ListPositionAllocator> positionAlloc = CreateObject<ListPositionAllocator> ();
  positionAlloc->Add (Vector (0.0, 20.0, 0.0));
  positionAlloc->Add (Vector (115.0, 20.0, 0.0)); //antes 137
  positionAlloc->Add (Vector (230.0, 20.0, 0.0));

  MobilityHelper mobility;
  mobility.SetPositionAllocator (positionAlloc);

  mobility.SetMobilityModel ("ns3::ConstantPositionMobilityModel");*/
  //fim teste

  //area baseada no shopping mall at millenia de 103.866 metros quadrados, estacionamento (320X360)
  //sem mobilidade - RANDOM BOX
  Ptr<UniformRandomVariable> randomizer = CreateObject<UniformRandomVariable> ();
  randomizer->SetAttribute ("Min", DoubleValue (20));
  randomizer->SetAttribute ("Max", DoubleValue (60));

  MobilityHelper mobility;
  mobility.SetPositionAllocator ("ns3::RandomBoxPositionAllocator",
                                 "X", PointerValue (randomizer),
                                 "Y", PointerValue (randomizer),
                                 "Z", PointerValue (NULL));
  
  mobility.SetMobilityModel ("ns3::ConstantPositionMobilityModel");

  //com mobilidade - NAO VEICULAR
  /*mobility.SetMobilityModel ("ns3::RandomWalk2dMobilityModel",
                             "Bounds", StringValue ("0|400|0|483"),
                             "Time", StringValue ("10s"),
                             "Speed", StringValue ("ns3::ConstantRandomVariable[Constant=2.0]"));
  */

  ////com mobilidade - VEICULAR
  /*MobilityHelper mobility;
  mobility.SetPositionAllocator ("ns3::HighwayPositionAllocator",
                                 "Start", VectorValue(Vector(0.0, 0.0, 0.0)),
                                 "Direction", DoubleValue(0.0),
                                 "Length", DoubleValue(1000.0),
                                 "MinGap", DoubleValue(distance),
                                 "MaxGap", DoubleValue(distance));

  mobility.SetMobilityModel("ns3::CustomConstantVelocityMobilityModel",
                            "ConstantVelocity", VectorValue(Vector(26.8224, 0, 0)));*/


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
  ndnHelper.SetContentStore ("ns3::ndn::cs::Lru", "MaxSize", "5");
  ndnHelper.SetContentStore ("ns3::ndn::cs::Nocache");
  //ndnHelper.SetContentStore ("ns3::ndn::cs::Lru",
  //                           "MaxSize", "10000");
  ndnHelper.SetDefaultRoutes(true);
  ndnHelper.Install(nodes);

  // 4. Set up applications
  NS_LOG_INFO ("Installing Applications");

  std::string prefix = "/prefix";

  // Consumer will request /prefix/0, /prefix/1, ...

  ndn::AppHelper consumerHelper ("ns3::ndn::ConsumerCbr");
  consumerHelper.SetPrefix (prefix);
  consumerHelper.SetAttribute ("Frequency", DoubleValue (1.0));
  consumerHelper.SetAttribute ("MaxSeq", IntegerValue (5));
  consumerHelper.Install (nodes.Get (2));
  /*consumerHelper.Install (nodes.Get (3));
  consumerHelper.Install (nodes.Get (6));
  consumerHelper.Install (nodes.Get (9));
  consumerHelper.Install (nodes.Get (12));*/

  // Producer will reply to all requests starting with /prefix

  ndn::AppHelper producerHelper ("ns3::ndn::Producer");
  producerHelper.SetPrefix (prefix);
  producerHelper.SetAttribute ("PayloadSize", StringValue("1024"));
  producerHelper.Install (nodes.Get (0));

  // 5. Set up applications << nos atacantes
  /*NS_LOG_INFO ("Installing Applications - Malicious Nodes");

  std::string prefixAttack = "/polluted";

  // Consumer will request /polluted/0, /polluted/1, ...

  ndn::AppHelper consumerHelperAttack ("ns3::ndn::ConsumerCbr");
  consumerHelperAttack.SetPrefix (producerHelperAttack);
  consumerHelperAttack.SetAttribute ("Frequency", DoubleValue (20.0));
  consumerHelperAttack.Install (nodes.Get (5));
  consumerHelperAttack.Install (nodes.Get (10));
  consumerHelperAttack.Install (nodes.Get (15));

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

  std::string tracer("resultados/ndn-no-cache-no-mob/experimento_");
  tracer = tracer.append(argv[2]);
  tracer = tracer.append("/rodada_");
  tracer = tracer.append(argv[3]);
  tracer = tracer.append("/trace.txt");

  boost::tuple< boost::shared_ptr<std::ostream>, std::list<boost::shared_ptr<ndn::V2vTracer> > >
    tracing = ndn::V2vTracer::InstallAll (tracer);

  cout << "Linha 175" << "\n";

  Simulator::Stop (Seconds (10.0));

  NS_LOG_INFO ("Starting");

  Simulator::Run ();

  NS_LOG_INFO ("Done");

  Simulator::Destroy ();

  return 0;
}
