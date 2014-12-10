/* -*- Mode: C++; c-file-style: "gnu"; indent-tabs-mode:nil -*- */
/*
 * Copyright (c) 2012-2013 University of California, Los Angeles
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
 * Author: Alexander Afanasyev <alexander.afanasyev@ucla.edu>
 */

#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/applications-module.h"
#include "ns3/wifi-module.h"
#include "ns3/mobility-module.h"
#include "ns3/internet-module.h"

#include "ns3/ndnSIM-module.h"

/*#include "ndn-v2v-net-device-face.h"
#include "l2-rate-tracer.h"
#include "ndn-app-delay-tracer.h"
#include "ndn-cs-tracer.h"
#include "ndn-l3-aggregate-tracer.h"
#include "ndn-l3-rate-tracer.h"
#include "ndn-l3-tracer.h"*/

#include <boost/shared_ptr.hpp>
#include <boost/make_shared.hpp>
#include <boost/lexical_cast.hpp>

using namespace std;
using namespace ns3;
using namespace boost;

NS_LOG_COMPONENT_DEFINE ("ndn.WifiExample");

//
// Modificado em setembro 2014 por Elise G Cieza
//
// DISCLAIMER:  Note that this is an extremely simple example, containing just 2 wifi nodes communicating
//              directly over AdHoc channel.
//

Ptr<ndn::NetDeviceFace>
V2vNetDeviceFaceCallback (Ptr<Node> node, Ptr<ndn::L3Protocol> ndn, Ptr<NetDevice> device)
{
  // NS_LOG_DEBUG ("Creating ndn::V2vNetDeviceFace on node " << node->GetId ());

  Ptr<ndn::NetDeviceFace> face = CreateObject<ndn::V2vNetDeviceFace> (node, device);
  ndn->AddFace (face);
  // NS_LOG_LOGIC ("Node " << node->GetId () << ": added NetDeviceFace as face #" << *face);

  return face;
}

int
main (int argc, char *argv[])
{
cout << "Linha 70" << "\n";
  uint32_t numberOfNodes = 3;

cout << "Linha 73" << "\n";

  if(argc > 1)
  {
     numberOfNodes = atoi(argv[1]);
     //cout<<"Numero: "<<atoi(argv[1])<<"\n";
     //cout<<"Primeiro parametro: "<<argv[0]<<"\n";
  }

  // disable fragmentation
  Config::SetDefault ("ns3::WifiRemoteStationManager::FragmentationThreshold", StringValue ("2200"));
  Config::SetDefault ("ns3::WifiRemoteStationManager::RtsCtsThreshold", StringValue ("2200"));
  Config::SetDefault ("ns3::WifiRemoteStationManager::NonUnicastMode", StringValue ("OfdmRate24Mbps"));

// v2v device
  Config::SetDefault ("ns3::ndn::V2vNetDeviceFace::MaxDelay", StringValue ("2ms"));
  Config::SetDefault ("ns3::ndn::V2vNetDeviceFace::MaxDelayLowPriority", StringValue ("5ms"));
  Config::SetDefault ("ns3::ndn::V2vNetDeviceFace::MaxDistance", StringValue ("250"));

  CommandLine cmd;
  cmd.Parse (argc,argv);

//--------------------------------------------------------------------------
//
// Configurando Wifi
//
//--------------------------------------------------------------------------


  WifiHelper wifi = WifiHelper::Default ();
  //wifi.SetRemoteStationManager ("ns3::AarfWifiManager");
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


  NqosWifiMacHelper wifiMacHelper = NqosWifiMacHelper::Default ();
  wifiMacHelper.SetType("ns3::AdhocWifiMac");

//--------------------------------------------------------------------------
//
// Mobilidade
//
//--------------------------------------------------------------------------


  /*Ptr<UniformRandomVariable> randomizer = CreateObject<UniformRandomVariable> ();
  randomizer->SetAttribute ("Min", DoubleValue (10));
  randomizer->SetAttribute ("Max", DoubleValue (100));*/

  /*MobilityHelper mobility;
  mobility.SetPositionAllocator ("ns3::RandomBoxPositionAllocator",
                                 "X", PointerValue (randomizer),
                                 "Y", PointerValue (randomizer),
                                 "Z", PointerValue (randomizer));
*/

  Ptr<ListPositionAllocator> positionAlloc = CreateObject<ListPositionAllocator> ();
  positionAlloc->Add (Vector (0.0, 20.0, 0.0));
  positionAlloc->Add (Vector (110.0, 20.0, 0.0)); //antes 137
  positionAlloc->Add (Vector (230.0, 20.0, 0.0));
  //positionAlloc->Add (Vector (300.0, 20.0, 0.0));  

  MobilityHelper mobility;
  mobility.SetPositionAllocator (positionAlloc);

  mobility.SetMobilityModel ("ns3::ConstantPositionMobilityModel");

cout << "Linha 145" << "\n";

  // Enable OLSR
  //OlsrHelper olsr;

  /*mobility.SetMobilityModel ("ns3::RandomWalk2dMobilityModel",
                             "Bounds", StringValue ("0|400|0|483"),
                             "Time", StringValue ("10s"),
                             "Speed", StringValue ("ns3::ConstantRandomVariable[Constant=2.0]"));
*/
//--------------------------------------------------------------------------
//
// Configurando nós
//
//--------------------------------------------------------------------------



  NodeContainer nodes;
  nodes.Create (numberOfNodes);

  // 1. Install Wifi
  NetDeviceContainer wifiNetDevices = wifi.Install (wifiPhyHelper, wifiMacHelper, nodes);

  // 2. Install Mobility model
  mobility.Install (nodes);

  // 3. Install NDN stack
  
  /*NS_LOG_INFO ("Installing NDN stack");
  ndn::StackHelper ndnHelper1;
  //ndnHelper1.AddNetDeviceFaceCreateCallback (WifiNetDevice::GetTypeId (), MakeCallback (MyNetDeviceFaceCallback));  
  ndnHelper1.SetForwardingStrategy ("ns3::ndn::fw::Flooding");
  ndnHelper1.SetContentStore ("ns3::ndn::cs::Lru", "MaxSize", "10000");
  ndnHelper1.SetDefaultRoutes (true);
  ndnHelper1.Install (nodes.Get (0));

  ndn::StackHelper ndnHelper2;
  ndnHelper2.AddNetDeviceFaceCreateCallback (WifiNetDevice::GetTypeId (), MakeCallback (MyNetDeviceFaceCallback));
  ndnHelper2.SetForwardingStrategy ("ns3::ndn::fw::Flooding");
  ndnHelper2.SetContentStore ("ns3::ndn::cs::Lru", "MaxSize", "10000");
  //ndnHelper2.SetPit ("ns3::ndn::pit::Persistent", "MaxSize", "0");
  ndnHelper2.SetDefaultRoutes (true);
  ndnHelper2.Install (nodes.Get (1));

  ndn::StackHelper ndnHelper3;
  //ndnHelper3.AddNetDeviceFaceCreateCallback (WifiNetDevice::GetTypeId (), MakeCallback (MyNetDeviceFaceCallback));
  ndnHelper3.SetForwardingStrategy ("ns3::ndn::fw::Flooding");
  ndnHelper3.SetContentStore ("ns3::ndn::cs::Lru", "MaxSize", "10000");
  ndnHelper3.SetDefaultRoutes (true);
  ndnHelper3.Install (nodes.Get (2));*/

  NS_LOG_INFO ("Installing NDN stack");
  ndn::StackHelper ndnHelper;
  ndnHelper.AddNetDeviceFaceCreateCallback (WifiNetDevice::GetTypeId (), MakeCallback (V2vNetDeviceFaceCallback));
  //ndnHelper.AddNetDeviceFaceCreateCallback (WifiNetDevice::GetTypeId (), MakeCallback (MyNetDeviceFaceCallback));
  ndnHelper.SetContentStore ("ns3::ndn::cs::Lru", "MaxSize", "5");
  //ndnHelper.SetContentStore ("ns3::ndn::cs::Nocache");
  //ndnHelper.SetForwardingStrategy ("ns3::ndn::fw::SmartFlooding");
  ndnHelper.SetForwardingStrategy ("ns3::ndn::fw::V2v");
  //ndnHelper.EnableLimits (true, Seconds (10.0), 10, 10);
  ndnHelper.SetDefaultRoutes (true);
  ndnHelper.Install (nodes);

  // 4. Set up applications
  NS_LOG_INFO ("Installing Applications");

  ndn::AppHelper consumerHelper ("ns3::ndn::ConsumerCbr");
  consumerHelper.SetPrefix ("/test/prefix");
  consumerHelper.SetAttribute ("Frequency", DoubleValue (1.0));
  consumerHelper.SetAttribute ("MaxSeq", IntegerValue (5));
  consumerHelper.Install (nodes.Get (0));

  ndn::AppHelper producerHelper ("ns3::ndn::Producer");
  producerHelper.SetPrefix ("/");
  producerHelper.SetAttribute ("PayloadSize", StringValue("120"));
  producerHelper.Install (nodes.Get (2));

//--------------------------------------------------------------------------
//
// Simulacao
//
//--------------------------------------------------------------------------

  Simulator::Stop (Seconds (10.0));

  // Tracers
 
  /*std::string appdelaytracer("resultados/ndn-test-hp/experimento_");
  appdelaytracer = appdelaytracer.append(argv[2]);
  appdelaytracer = appdelaytracer.append("/rodada_");
  appdelaytracer = appdelaytracer.append(argv[3]);
  appdelaytracer = appdelaytracer.append("/trace-app-delays.txt");
cout << "String: "  << appdelaytracer << "\n";
  ndn::AppDelayTracer::InstallAll (appdelaytracer);*/
 
  /*std::string cstracer("resultados/ndn-no-cache-no-mob/experimento_");
  cstracer = cstracer.append(argv[2]);
  cstracer = cstracer.append("/rodada_");
  cstracer = cstracer.append(argv[3]);
  cstracer = cstracer.append("/trace-cs.txt");
  ndn::CsTracer::InstallAll (cstracer, Seconds (1));

  std::string l3agg("resultados/ndn-test-hp/experimento_");
  l3agg = l3agg.append(argv[2]);
  l3agg = l3agg.append("/rodada_");
  l3agg = l3agg.append(argv[3]);
  l3agg = l3agg.append("/trace-aggregate.txt");
  ndn::L3AggregateTracer::InstallAll(l3agg, Seconds (1));
 
  std::string l2rate("resultados/ndn-test-hp/experimento_");
  l2rate = l2rate.append(argv[2]);
  l2rate = l2rate.append("/rodada_");
  l2rate = l2rate.append(argv[3]);
  l2rate = l2rate.append("/trace-l2Drop.txt");
  ns3::L2RateTracer::InstallAll(l2rate, Seconds (1));

  std::string l3rate("resultados/ndn-test-hp/experimento_");
  l3rate = l3rate.append(argv[2]);
  l3rate = l3rate.append("/rodada_");
  l3rate = l3rate.append(argv[3]);
  l3rate = l3rate.append("/trace-rate.txt");
  ndn::L3RateTracer::InstallAll (l3rate, Seconds (1.0));*/

  Simulator::Run ();
  Simulator::Destroy ();

  return 0;
}
