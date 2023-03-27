/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2013-2023 MyFlightbook, LLC
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  CollapsibleTable.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/26/23.
//

import Foundation

/// Swift version of the CollapsibleTable class
/// MUST coexist with CollapsibleTable during swift transition because it relies on Swift protocols/classes
/// Since objc-classes can't inherit from a swift class, we can't migrate child classes unless/until
/// this is migrated without including collapsibletable.h in the bridging header, but if we do that, we get
/// circular references.
/// So this will duplicate the objc class, and swift classes can inherit from this.
/// We will do the same for pullrefreshtableviewcontroller
/*
 public class CollapsibleTableSw : UITableViewController, UIImagePickerControllerDelegate, AccessoryBarDelegate, Invalidatable, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
 
 }
 */
