/* -*- Mode:C++; c-file-style:"gnu"; indent-tabs-mode:nil; -*- */
/*
 * Copyright (c) 2006,2007 INRIA
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
 * Author: Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
 */
#include "vehicular-2d-mobility-model.h"
#include "ns3/enum.h"
#include "ns3/double.h"
#include "ns3/string.h"
#include "ns3/pointer.h"
#include "ns3/simulator.h"
#include "ns3/log.h"
#include <cmath>

NS_LOG_COMPONENT_DEFINE ("Vehicular2d");

namespace ns3 {

NS_OBJECT_ENSURE_REGISTERED (Vehicular2dMobilityModel);

TypeId
Vehicular2dMobilityModel::GetTypeId (void)
{
  static TypeId tid = TypeId ("ns3::Vehicular2dMobilityModel")
    .SetParent<MobilityModel> ()
    .SetGroupName ("Mobility")
    .AddConstructor<Vehicular2dMobilityModel> ()
    .AddAttribute ("Bounds",
                   "Bounds of the area to cruise.",
                   RectangleValue (Rectangle (0.0, 0.0, 100.0, 100.0)),
                   MakeRectangleAccessor (&Vehicular2dMobilityModel::m_bounds),
                   MakeRectangleChecker ())
    .AddAttribute ("Time",
                   "Change current direction and speed after moving for this delay.",
                   TimeValue (Seconds (1.0)),
                   MakeTimeAccessor (&Vehicular2dMobilityModel::m_modeTime),
                   MakeTimeChecker ())
    .AddAttribute ("Distance",
                   "Change current direction and speed after moving for this distance.",
                   DoubleValue (1.0),
                   MakeDoubleAccessor (&Vehicular2dMobilityModel::m_modeDistance),
                   MakeDoubleChecker<double> ())
   .AddAttribute ("UniqueDirection",
				  "Este nó terá apenas uma unica direcao?",
				  DoubleValue (0.0),
				  MakeDoubleAccessor (&Vehicular2dMobilityModel::m_uniqueDirection),
				  MakeDoubleChecker<double> ())
    .AddAttribute ("Mode",
                   "The mode indicates the condition used to "
                   "change the current speed and direction",
                   EnumValue (Vehicular2dMobilityModel::MODE_DISTANCE),
                   MakeEnumAccessor (&Vehicular2dMobilityModel::m_mode),
                   MakeEnumChecker (Vehicular2dMobilityModel::MODE_DISTANCE, "Distance",
                		   Vehicular2dMobilityModel::MODE_TIME, "Time"))
    .AddAttribute ("Direction",
                   "A random variable used to pick the direction (gradients).",
                   StringValue ("ns3::UniformRandomVariable[Min=0.0|Max=6.283184]"),
                   MakePointerAccessor (&Vehicular2dMobilityModel::m_direction),
                   MakePointerChecker<RandomVariableStream> ())
    .AddAttribute ("Speed",
                   "A random variable used to pick the speed (m/s).",
                   StringValue ("ns3::UniformRandomVariable[Min=2.0|Max=4.0]"),
                   MakePointerAccessor (&Vehicular2dMobilityModel::m_speed),
                   MakePointerChecker<RandomVariableStream> ());
  return tid;
}

void
Vehicular2dMobilityModel::DoInitialize (void)
{
  DoInitializePrivate ();
  MobilityModel::DoInitialize ();
}

void
Vehicular2dMobilityModel::DoInitializePrivate (void)
{
  m_helper.Update ();
  double speed = m_speed->GetValue ();
  //inicio adriano
  //double direction = m_direction->GetValue (); //linha original
  // tenho q coletar a direcao inicial do no para faze-lo nao retroceder!!!!
  // se for um no consumidor (tomara apenas uma direcao) entao coletara a direcao
  // indicada pelo parametro m_direction
  double direction;
  if (m_uniqueDirection == 0.0)
	  direction = m_helper.GetNewDirection();
  else
	  direction = m_direction->GetValue();
  //fim adriano
  Vector vector (std::cos (direction) * speed,
                 std::sin (direction) * speed,
                 0.0);
  m_helper.SetVelocity (vector);
  m_helper.Unpause ();

  Time delayLeft;
  if (m_mode == Vehicular2dMobilityModel::MODE_TIME)
    {
      delayLeft = m_modeTime;
    }
  else
    {
      delayLeft = Seconds (m_modeDistance / speed); 
    }
  DoWalk (delayLeft);
}

void
Vehicular2dMobilityModel::DoWalk (Time delayLeft)
{
  Vector position = m_helper.GetCurrentPosition ();
  Vector speed = m_helper.GetVelocity ();
  Vector nextPosition = position;
  nextPosition.x += speed.x * delayLeft.GetSeconds ();
  nextPosition.y += speed.y * delayLeft.GetSeconds ();
  m_event.Cancel ();
  if (m_bounds.IsInside (nextPosition))
    {
      m_event = Simulator::Schedule (delayLeft, &Vehicular2dMobilityModel::DoInitializePrivate, this);
    }
  else
    {
      nextPosition = m_bounds.CalculateIntersection (position, speed);
      Time delay = Seconds ((nextPosition.x - position.x) / speed.x);
      m_event = Simulator::Schedule (delay, &Vehicular2dMobilityModel::Rebound, this,
                                     delayLeft - delay);
    }
  NotifyCourseChange ();
}

void
Vehicular2dMobilityModel::Rebound (Time delayLeft)
{
  m_helper.UpdateWithBounds (m_bounds);
  Vector position = m_helper.GetCurrentPosition ();
  Vector speed = m_helper.GetVelocity ();
  switch (m_bounds.GetClosestSide (position))
    {
    case Rectangle::RIGHT:
    case Rectangle::LEFT:
      speed.x = -speed.x;
      break;
    case Rectangle::TOP:
    case Rectangle::BOTTOM:
      speed.y = -speed.y;
      break;
    }
  m_helper.SetVelocity (speed);
  m_helper.Unpause ();
  DoWalk (delayLeft);
}

void
Vehicular2dMobilityModel::DoDispose (void)
{
  // chain up
  MobilityModel::DoDispose ();
}
Vector
Vehicular2dMobilityModel::DoGetPosition (void) const
{
  m_helper.UpdateWithBounds (m_bounds);
  return m_helper.GetCurrentPosition ();
}
void
Vehicular2dMobilityModel::DoSetPosition (const Vector &position)
{
  NS_ASSERT (m_bounds.IsInside (position));
  m_helper.SetPosition (position);
  Simulator::Remove (m_event);
  m_event = Simulator::ScheduleNow (&Vehicular2dMobilityModel::DoInitializePrivate, this);
}
Vector
Vehicular2dMobilityModel::DoGetVelocity (void) const
{
  return m_helper.GetVelocity ();
}
int64_t
Vehicular2dMobilityModel::DoAssignStreams (int64_t stream)
{
  m_speed->SetStream (stream);
  m_direction->SetStream (stream + 1);
  return 2;
}


} // namespace ns3
