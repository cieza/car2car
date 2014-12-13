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
 *
 */

#include "v2v-tracer.h"
#include "ns3/node.h"
#include "ns3/packet.h"
#include "ns3/config.h"
#include "ns3/callback.h"
#include "ns3/simulator.h"
#include "ns3/log.h"
#include "ns3/node-list.h"
#include "ns3/names.h"

#include "ns3/ndn-l3-protocol.h"
#include "ns3/ndn-content-store.h"
#include "ns3/ndn-forwarding-strategy.h"
#include "ns3/ndn-app.h"
#include "ns3/ndn-face.h"
#include "ns3/ndn-interest.h"
#include "ns3/ndn-content-object.h"

#include <fstream>
#include <boost/lexical_cast.hpp>
#include <boost/make_shared.hpp>

using namespace boost;
using namespace std;

NS_LOG_COMPONENT_DEFINE ("V2vTracer");

namespace ns3 {
    namespace ndn {
        
        
        boost::tuple< boost::shared_ptr<std::ostream>, std::list<boost::shared_ptr<V2vTracer> > >
        V2vTracer::InstallAll (const std::string &file)
        {
            std::list<boost::shared_ptr<V2vTracer> > tracers;
            boost::shared_ptr<std::ofstream> outputStream (new std::ofstream ());
            outputStream->open (file.c_str (), std::ios_base::out | std::ios_base::trunc);
            
            if (!outputStream->is_open ())
                return boost::make_tuple (outputStream, tracers);
            
            for (NodeList::Iterator node = NodeList::Begin ();
                 node != NodeList::End ();
                 node++)
            {
                NS_LOG_DEBUG ("Node: " << lexical_cast<string> ((*node)->GetId ()));
                
                boost::shared_ptr<V2vTracer> trace = make_shared<V2vTracer> (outputStream, *node);
                tracers.push_back (trace);
            }
            
            if (tracers.size () > 0)
            {
                // *m_l3RateTrace << "# "; // not necessary for R's read.table
                tracers.front ()->PrintHeader (*outputStream);
                *outputStream << "\n";
            }
            
            return boost::make_tuple (outputStream, tracers);
        }
        
        void
        V2vTracer::PrintHeader (std::ostream &os) const
        {
            os << "Time" << "\t"
            
            << "Node" << "\t"
            
            << "Event" << "\t"
            << "SeqNo";
        }
        
        V2vTracer::V2vTracer (boost::shared_ptr<std::ostream> os, Ptr<Node> node)
        : m_nodePtr (node)
        , m_os (os)
        {
            m_node = boost::lexical_cast<string> (m_nodePtr->GetId ());
            
            Connect ();
            
            string name = Names::FindName (node);
            if (!name.empty ())
            {
                m_node = name;
            }
            
        }
        
        void
        V2vTracer::Connect ()
        {
            m_nodePtr->GetObject<ContentStore> ()->TraceConnectWithoutContext ("DidAddEntry", MakeCallback (&V2vTracer::DidAddEntry, this));
            
            m_nodePtr->GetObject<ForwardingStrategy> ()->TraceConnectWithoutContext ("InInterests", MakeCallback (&V2vTracer::InInterest, this));
            
            
            Ptr<L3Protocol> ndn = m_nodePtr->GetObject<L3Protocol> ();
            for (uint32_t faceId = 0; faceId < ndn->GetNFaces (); faceId++)
            {
                ndn->GetFace (faceId)->TraceConnectWithoutContext ("Canceling", MakeCallback (&V2vTracer::Canceling, this));
            }
            
            Config::ConnectWithoutContext ("/NodeList/"+m_node+"/DeviceList/*/$ns3::WifiNetDevice/Phy/PhyTxBegin", MakeCallback (&V2vTracer::PhyOutData, this));
        }
        
        void
        V2vTracer::DidAddEntry (Ptr<const cs::Entry> csEntry)
        {
            *m_os << Simulator::Now ().ToDouble (Time::S) << "\t"
            << m_node << "\t" << "DataCached" << "\t" << csEntry->GetName ().GetLastComponent () << "\n";
            
            //cout << "Node: " << m_node << " Dado: " << csEntry->GetName () << " SeqNum: " << csEntry->GetName ().GetLastComponent () << "\n";
            
            if (data_map.find(csEntry->GetName ().GetLastComponent ()) != data_map.end())
            {
                int num = data_map[csEntry->GetName ().GetLastComponent ()];
                num++;
                data_map[csEntry->GetName ().GetLastComponent ()] = num;   }
            else
            {
                data_map[csEntry->GetName ().GetLastComponent ()]  = 1;
            }
            
            if(interest_map.find(csEntry->GetName ().GetLastComponent ()) != interest_map.end())
            {
                if (satisfied_data_map.find(csEntry->GetName ().GetLastComponent ()) != satisfied_data_map.end())
                {
                    int num = satisfied_data_map[csEntry->GetName ().GetLastComponent ()];
                    num++;
                    satisfied_data_map[csEntry->GetName ().GetLastComponent ()] = num;   }
                else
                {
                    satisfied_data_map[csEntry->GetName ().GetLastComponent ()]  = 1;
                    delay_map[csEntry->GetName ().GetLastComponent ()]  = (Simulator::Now ().ToDouble (Time::S)) - init_time_map[csEntry->GetName ().GetLastComponent ()];
                    cout<<"Atraso Node: "<<m_node<<" Delay: "<<delay_map[csEntry->GetName ().GetLastComponent ()]<<"\n";
                }
            }
            
            
            
            Ptr<cs::Entry> auxEntry = m_nodePtr->GetObject<ContentStore> ()->Begin ();
            //cout<<"CONTENT STORE Node: "<<m_node<<"\n";
            int num_total = 0;
            int num_poluidos = 0;
            
            if(auxEntry != NULL)
            {
                do{
                    
                    //cout<<auxEntry->GetName ()<<"   begin: "<<auxEntry->GetName ().GetComponents().front()<<"\n";
                    num_total++;
                    if(auxEntry->GetName ().GetComponents().front().compare("polluted") == 0)
                    {
                        num_poluidos++;
                    }
                    auxEntry = m_nodePtr->GetObject<ContentStore> ()->Next (auxEntry);
                }while(auxEntry != NULL);
                double ocupacao_maliciosa = num_poluidos;
                ocupacao_maliciosa = ocupacao_maliciosa/num_total;
                cout<<"Ocupacao_Maliciosa  Node: "<<m_node<<"  num_poluidos: "<<num_poluidos<<" num_total: "<<num_total<<"\n";
            }
            else
            {
                //cout<<"Vazio\n";
            }
            
            
            int num = 0;
            for (std::map<std::string,int>::iterator it=interest_map.begin(); it!=interest_map.end(); ++it)
            {
                num = num+it->second;
                //cout << it->first << "  => " << it->second << '\n';
            }
            if(num != 0)
            {
                double taxa = satisfied_data_map.size();
                taxa = taxa/num;
                //cout << "Node: " << m_node << " Taxa de entrega: " << taxa << "\n";
                
                double taxa_absoluta = satisfied_data_map.size();
                taxa_absoluta = taxa_absoluta/interest_map.size();
                cout << "Taxa_Entrega_Absoluta   Node: " << m_node << " Satisfeitos: " << satisfied_data_map.size() << " Interesses: " << interest_map.size()<< "\n";
            }
            
            //cout << "Node: " << m_node << " Num de dados totais: " << data_map.size() << "\n";
            //cout << "Node: " << m_node << " Num de interesses satisfeitos totais: " << satisfied_data_map.size() << "\n";
            
            /*for (std::map<std::string,int>::iterator it=data_map.begin(); it!=data_map.end(); ++it)
             {
             //cout << it->first << "  => " << it->second << '\n';
             }*/
        }
        
        
        void
        V2vTracer::InInterest (Ptr<const Interest> header, Ptr<const Face> face)
        {
            *m_os << Simulator::Now ().ToDouble (Time::S) << "\t"
            << m_node << "\t" << "Incoming interest" << "\t" << header->GetName ().GetLastComponent () << "\n";
            
            //cout << "Node: " << m_node << " Interesse: " << header->GetName () << " SeqNum: " << header->GetName ().GetLastComponent () << " Face: " << face->GetId() << "\n";
            
            //verifica se a face igual a 1, ou seja, a face da aplicacao e se o prefixo e diferente de polluted, so contabiliza se for prefix
            if(face->GetId() == 1 && (header->GetName ().GetComponents().front().compare("polluted") != 0))
            {
                //verifica se interesse já se encontra no mapa de interesses
                if (interest_map.find(header->GetName ().GetLastComponent ()) != interest_map.end())
                {
                    int num = interest_map[header->GetName ().GetLastComponent ()];
                    num++;
                    interest_map[header->GetName ().GetLastComponent ()] = num;
                }
                else
                {
                    interest_map[header->GetName ().GetLastComponent ()]  = 1;
                    init_time_map[header->GetName ().GetLastComponent ()] = Simulator::Now ().ToDouble (Time::S);
                }
            }
            
            //cout << "Node: " << m_node << " Num de interesses totais: " << interest_map.size() << "\n";
            //cout << "Node: " << m_node << " Num de interesses satisfeitos totais: " << satisfied_data_map.size() << "\n";
            int num = 0;
            for (std::map<std::string,int>::iterator it=interest_map.begin(); it!=interest_map.end(); ++it)
            {
                num = num+it->second;
                //cout << it->first << "  => " << it->second << '\n';
            }
            if(num != 0)
            {
                double taxa = satisfied_data_map.size();
                taxa = taxa/num;
                //cout << "Node: " << m_node << " Taxa de entrega: " << taxa << "\n";
                
                double taxa_absoluta = satisfied_data_map.size();
                taxa_absoluta = taxa_absoluta/interest_map.size();
                cout << "Taxa_Entrega_Absoluta   Node: " << m_node << " Satisfeitos: " << satisfied_data_map.size() << " Interesses: " << interest_map.size()<< "\n";
            }
            
        }
        
        void
        V2vTracer::PhyOutData (Ptr<const Packet> packet)
        {
            *m_os << Simulator::Now ().ToDouble (Time::S) << "\t"
            << m_node << "\t" << "Broadcasting" << "\t" << *packet/*->PeekPacketTag<CcnxNameComponentsTag> ()->GetName ()->GetLastComponent ()*/ << "\n";
            
        }
        
        void
        V2vTracer::Canceling (Ptr<Node> node, Ptr<const Packet> packet)
        {
            // NS_LOG_INFO( "Dropping packet due to noise or error model calculation." );
            *m_os << Simulator::Now ().ToDouble (Time::S) << "\t"
            << m_node << "\t" << "Canceling transmission" << "\t" << *packet/*->PeekPacketTag<CcnxNameComponentsTag> ()->GetName ()->GetLastComponent ()*/ << "\n";
        }
        
    } // namespace ndn
} // namespace ns3
