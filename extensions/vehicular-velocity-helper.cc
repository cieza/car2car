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
#include "ns3/simulator.h"
#include "ns3/rectangle.h"
#include "ns3/box.h"
//adriano
#include "ns3/random-variable.h"
#include "vehicular-velocity-helper.h"

namespace ns3 {

VehicularVelocityHelper::VehicularVelocityHelper ()
  : m_paused (true)
{
	//elise
	m_initialDirection = 0;
}
VehicularVelocityHelper::VehicularVelocityHelper (const Vector &position)
  : m_position (position),
    m_paused (true)
{
	//elise
	m_initialDirection = 0;
}
VehicularVelocityHelper::VehicularVelocityHelper (const Vector &position,
                                                const Vector &vel)
  : m_position (position),
    m_velocity (vel),
    m_paused (true)
{
	//elise
	m_initialDirection = 0;
}
void
VehicularVelocityHelper::SetPosition (const Vector &position)
{
  m_position = position;
  m_velocity = Vector (0.0, 0.0, 0.0);
  m_lastUpdate = Simulator::Now ();
}

Vector
VehicularVelocityHelper::GetCurrentPosition (void) const
{
  return m_position;
}

Vector 
VehicularVelocityHelper::GetVelocity (void) const
{
  return m_paused ? Vector (0.0, 0.0, 0.0) : m_velocity;
}
void 
VehicularVelocityHelper::SetVelocity (const Vector &vel)
{
  m_velocity = vel;
  m_lastUpdate = Simulator::Now ();
}

void
VehicularVelocityHelper::Update (void) const
{
  Time now = Simulator::Now ();
  NS_ASSERT (m_lastUpdate <= now);
  Time deltaTime = now - m_lastUpdate;
  m_lastUpdate = now;
  if (m_paused)
    {
      return;
    }
  double deltaS = deltaTime.GetSeconds ();
  m_position.x += m_velocity.x * deltaS;
  m_position.y += m_velocity.y * deltaS;
  m_position.z += m_velocity.z * deltaS;
}

void
VehicularVelocityHelper::UpdateWithBounds (const Rectangle &bounds) const
{
  Update ();
  m_position.x = std::min (bounds.xMax, m_position.x);
  m_position.x = std::max (bounds.xMin, m_position.x);
  m_position.y = std::min (bounds.yMax, m_position.y);
  m_position.y = std::max (bounds.yMin, m_position.y);
}

void
VehicularVelocityHelper::UpdateWithBounds (const Box &bounds) const
{
  Update ();
  m_position.x = std::min (bounds.xMax, m_position.x);
  m_position.x = std::max (bounds.xMin, m_position.x);
  m_position.y = std::min (bounds.yMax, m_position.y);
  m_position.y = std::max (bounds.yMin, m_position.y);
  m_position.z = std::min (bounds.zMax, m_position.z);
  m_position.z = std::max (bounds.zMin, m_position.z);
}

void 
VehicularVelocityHelper::Pause (void)
{
  m_paused = true;
}

void 
VehicularVelocityHelper::Unpause (void)
{
  m_paused = false;
}


//adriano >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

int
VehicularVelocityHelper::SortNewDirection (void)
{
	//sorteio de variavel que determinara direcao
	UniformVariable uv;
	uint16_t sort = uint16_t((uv.GetValue()*10)) % 4;
	return sort;
}


double
VehicularVelocityHelper::GetNewDirection (void)
{
	if (m_initialDirection < 0){
		m_initialDirection = SortNewDirection();
		m_atualDirection = m_initialDirection;
		//std::cout << "Set Direcao inicial: " << m_atualDirection << std::endl;
	} else {
		int val = SortNewDirection();
		if ((m_atualDirection == 0) && (val == 2)) val = 1; else
		if ((m_atualDirection == 1) && (val == 3)) val = 2; else
		if ((m_atualDirection == 2) && (val == 0)) val = 3; else
		if ((m_atualDirection == 3) && (val == 1)) val = 0;

		if ((m_initialDirection == 0) && (val == 2)) val = 0; else
		if ((m_initialDirection == 1) && (val == 3)) val = 1; else
		if ((m_initialDirection == 2) && (val == 0)) val = 2; else
		if ((m_initialDirection == 3) && (val == 1)) val = 3;
		m_atualDirection = val;
		//std::cout << "Set nova Direcao : " << m_atualDirection << endl;
	}

	if (m_atualDirection == 0) return double_t(0.000000); // movimento para a frente
	if (m_atualDirection == 1) return double_t(1.570796); // movimento para cima
	if (m_atualDirection == 2) return double_t(3.141592); // movimento para tras
	if (m_atualDirection == 3) return double_t(4.712388); // movimento para baixo
	return double_t(0.0);
}

//fim adriano


} // namespace ns3
