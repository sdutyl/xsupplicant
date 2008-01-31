/**
 * The XSupplicant User Interface is Copyright 2007, 2008 Identity Engines.
 * Identity Engines provides the XSupplicant User Interface under dual license terms.
 *
 *   For open source projects, if you are developing and distributing open source 
 *   projects under the GPL License, then you are free to use the XSupplicant User 
 *   Interface under the GPL version 2 license.
 *
 *  --- GPL Version 2 License ---
 *
 *  This program is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU General Public License, Version 2
 *  as published by the Free Software Foundation.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License, Version 2 for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.  
 *  You may also find the license at the following link
 *  http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt .
 *
 *
 *   For commercial enterprises, OEMs, ISVs and VARs, if you want to distribute or 
 *   incorporate the XSupplicant User Interface with your products and do not license
 *   and distribute your source code for those products under the GPL, please contact
 *   Identity Engines for an OEM Commercial License.
 **/

#include <QWidget>

#include "stdafx.h"
#include "ConfigWidgetTrustedServersTable.h"
#include "Util.h"
#include "NavPanel.h"

ConfigWidgetTrustedServersTable::ConfigWidgetTrustedServersTable(QTableWidget *pRealTable, trusted_servers_enum *pTrustedServersEnum, QWidget *parent) :
	m_pRealTable(pRealTable), m_pParent(parent), m_pTrustedServersEnum(pTrustedServersEnum)
{
	m_bConnected = false;

	m_pRealTable->horizontalHeader()->setDefaultAlignment(Qt::AlignCenter);
	m_pRealTable->horizontalHeader()->setStretchLastSection(true);
	m_pRealTable->horizontalHeader()->setHighlightSections(false);   // Don't "push in" the header.
	m_pRealTable->verticalHeader()->setHighlightSections(false);     // Ditto for the vertical header.

	Util::myConnect(this, SIGNAL(signalSetSaveBtn(bool)), parent, SIGNAL(signalSetSaveBtn(bool)));

	// Make sure the save button is disabled.
	emit signalSetSaveBtn(false);
}

ConfigWidgetTrustedServersTable::~ConfigWidgetTrustedServersTable()
{	
	if (m_pRealTable != NULL)
	{
		for (int i = m_pRealTable->rowCount(); i >= 0; i--)
		{
			m_pRealTable->removeRow(i);
		}
	}

	if (m_bConnected)
	{
		Util::myDisconnect(m_pRealTable, SIGNAL(cellDoubleClicked(int, int)), this, SLOT(slotDoubleClicked(int, int)));
		Util::myDisconnect(this, SIGNAL(signalSetWidget(int, const QString &)), m_pParent, SLOT(slotSetWidget(int, const QString &)));
		Util::myDisconnect(this, SIGNAL(signalNavChangeSelected(int, const QString &)), m_pParent, SIGNAL(signalNavChangeSelected(int, const QString &)));
		Util::myDisconnect(m_pParent, SIGNAL(signalHelpClicked()), this, SLOT(slotShowHelp()));
	}
}

bool ConfigWidgetTrustedServersTable::attach()
{
	int i = 0;
	QTableWidgetItem *newItem = NULL;

	while (m_pTrustedServersEnum[i].name != NULL)
	{
		m_pRealTable->insertRow(i);
		newItem = new QTableWidgetItem(QString(m_pTrustedServersEnum[i].name), 0);
		m_pRealTable->setItem(i, 0, newItem);
		i++;
	}

	Util::myConnect(m_pRealTable, SIGNAL(cellDoubleClicked(int, int)), this, SLOT(slotDoubleClicked(int, int)));
	Util::myConnect(this, SIGNAL(signalSetWidget(int, const QString &)), m_pParent, SLOT(slotSetWidget(int, const QString &)));
	Util::myConnect(this, SIGNAL(signalNavChangeSelected(int, const QString &)), m_pParent, SIGNAL(signalNavChangeSelected(int, const QString &)));
	Util::myConnect(m_pParent, SIGNAL(signalHelpClicked()), this, SLOT(slotShowHelp()));

	m_bConnected = true;

	return true;
}

void ConfigWidgetTrustedServersTable::slotDoubleClicked(int row, int column)
{
	QTableWidgetItem *myItem = NULL;

	// We only care about the row.
	myItem = m_pRealTable->item(row, column);

	emit signalNavChangeSelected(NavPanel::TRUSTED_SERVERS_ITEM, myItem->text());
	emit signalSetWidget(NavPanel::TRUSTED_SERVERS_ITEM, myItem->text());
}

void ConfigWidgetTrustedServersTable::slotShowHelp()
{
	HelpBrowser::showPage("xsupphelp.html", "xsupservermain");
}
