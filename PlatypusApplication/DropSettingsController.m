/*
    Platypus - program for creating Mac OS X application wrappers around scripts
    Copyright (C) 2003-2012 Sveinbjorn Thordarson <sveinbjornt@gmail.com>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

*/

#import "DropSettingsController.h"
#import "Common.h"

@implementation DropSettingsController

/*****************************************
 - init function
*****************************************/

- (id)init
{
	if (self = [super init]) 
	{
		typesList = [[TypesList alloc] init];
		suffixList = [[SuffixList alloc] init];
    }
    return self;
}

/*****************************************
 - dealloc for controller object
   release all the stuff we alloc in init
*****************************************/

-(void)dealloc
{
	[typesList release];
	[suffixList release];
	[super dealloc];
}

#pragma mark -

- (void)awakeFromNib
{
	[typesListDataBrowser registerForDraggedTypes: [NSArray arrayWithObject: NSFilenamesPboardType]];
	[suffixListDataBrowser registerForDraggedTypes: [NSArray arrayWithObject: NSFilenamesPboardType]];
}

/*****************************************
 - Display the Edit Types Window as a sheet
*****************************************/

- (IBAction) openTypesSheet: (id)sender
{
	[window setTitle: [NSString stringWithFormat: @"%@ - Drop settings", PROGRAM_NAME]];
	//clear text fields from last time
	[typeCodeTextField setStringValue: @""];
	[suffixTextField setStringValue: @""];
	
	// refresh these guys
    [typesListDataBrowser setDataSource: typesList];
	[typesListDataBrowser reloadData];
	[typesListDataBrowser setDelegate: self];
	[typesListDataBrowser setTarget: self];

    [suffixListDataBrowser setDataSource: suffixList];
	[suffixListDataBrowser reloadData];
	[suffixListDataBrowser setDelegate: self];
	[suffixListDataBrowser setTarget: self];
    
	// updated text fields reporting no. suffixes and no. file type codes
	if ([suffixList hasAllSuffixes])
		[numSuffixesTextField setStringValue: @"All suffixes"];
	else
		[numSuffixesTextField setStringValue: [NSString stringWithFormat:@"%d suffixes", [suffixList numSuffixes]]];

	if ([typesList hasAllTypes])
		[numTypesTextField setStringValue: @"All file types"];
	else
		[numTypesTextField setStringValue: [NSString stringWithFormat:@"%d file types", [typesList numTypes]]];
	if ([typesList hasFolderType])
		[numTypesTextField setStringValue: [[numTypesTextField stringValue] stringByAppendingString: @" and folders"]];
		
	//open window
	[NSApp beginSheet:	typesWindow
						modalForWindow: window 
						modalDelegate:nil
						didEndSelector:nil
						contextInfo:nil];

	 [NSApp runModalForWindow: typesWindow];
	 
	 [NSApp endSheet:typesWindow];
     [typesWindow orderOut:self];
}

- (IBAction)closeTypesSheet:(id)sender
{
	//make sure typeslist contains valid values
	if ([typesList numTypes] <= 0 && [suffixList numSuffixes] <= 0)
	{
		[typesErrorTextField setStringValue: @"One of the lists must contain at least one entry."];
	}
	else
	{
		[typesErrorTextField setStringValue: @""];
		[window setTitle: PROGRAM_NAME];
		[NSApp stopModal];
		[NSApp endSheet:typesWindow];
		[typesWindow orderOut:self];
	}
}

#pragma mark -

- (IBAction)acceptDroppedFilesClicked:(id)sender
{
	if ([acceptDroppedFilesCheckbox intValue])
	{
		
	}
	else
	{
		
	}
}

#pragma mark -

//create open panel


- (IBAction)selectDocIcon:(id)sender
{
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
	[oPanel setPrompt: @"Select"];
    [oPanel setAllowsMultipleSelection:NO];
	[oPanel setCanChooseDirectories: NO];
    [oPanel setTitle: @"Select an icns file"];
    [oPanel setPrompt: @"Select"];
        
    if ([oPanel runModalForDirectory: nil file: nil types: [NSArray arrayWithObject: @"icns"]] == NSOKButton)
        [self setDocIconPath: [oPanel filename]];
}

#pragma mark -

/*****************************************
 - called when [+] button is pressed in Types List
*****************************************/

- (IBAction) addSuffix:(id)sender;
{
	NSString	*theSuffix = [suffixTextField stringValue];
	
	if ([suffixList hasSuffix: theSuffix] || ([theSuffix length] == 0))
		return;
		
	//if the user put in a suffix beginning with a '.', we trim the string to start from index 1
	if ([theSuffix characterAtIndex: 0] == '.')
		theSuffix = [theSuffix substringFromIndex: 1];

	[suffixList addSuffix: theSuffix];
	[suffixTextField setStringValue: @""];
	[self controlTextDidChange: NULL];

	//update
	[suffixListDataBrowser reloadData];
	
	if ([suffixList hasAllSuffixes])
		[numSuffixesTextField setStringValue: @"All suffixes"];
	else
		[numSuffixesTextField setStringValue: [NSString stringWithFormat:@"%d suffixes", [suffixList numSuffixes]]];
}

/*****************************************
 - called when [+] button is pressed in Types List
*****************************************/

- (IBAction) addType:(id)sender;
{
	//make sure the type is 4 characters long
	if ([[typeCodeTextField stringValue] length] != 4)
	{
				[PlatypusUtility sheetAlert:@"Invalid File Type" subText: @"A File Type must consist of exactly 4 ASCII characters." forWindow: typesWindow];
		return;
	}

	if (![typesList hasType: [typeCodeTextField stringValue]] && ([[typeCodeTextField stringValue] length] > 0))
	{
		[typesList addType: [typeCodeTextField stringValue]];
		[typeCodeTextField setStringValue: @""];
		[self controlTextDidChange: NULL];
	}
	//update
	[typesListDataBrowser reloadData];
	
	if ([typesList hasAllTypes])
		[numTypesTextField setStringValue: @"All file types"];
	else
		[numTypesTextField setStringValue: [NSString stringWithFormat:@"%d file types", [typesList numTypes]]];
	if ([typesList hasFolderType])
		[numTypesTextField setStringValue: [[numTypesTextField stringValue] stringByAppendingString: @" and folders"]];
}

/*****************************************
 - called when [C] button is pressed in Types List
*****************************************/

- (IBAction) clearSuffixList:(id)sender
{
	[suffixList clearList];
	[suffixListDataBrowser reloadData];
	[numSuffixesTextField setStringValue: [NSString stringWithFormat:@"%d suffixes", [suffixList numSuffixes]]];
}

/*****************************************
 - called when [C] button is pressed in Types List
*****************************************/

- (IBAction) clearTypesList:(id)sender
{
	[typesList clearList];
	[typesListDataBrowser reloadData];
	[numTypesTextField setStringValue: [NSString stringWithFormat:@"%d file types", [typesList numTypes]]];
}

/*****************************************
 - called when [-] button is pressed in Types List
*****************************************/

- (IBAction) removeSuffix:(id)sender;
{
	int i;
	NSIndexSet *selectedItems = [suffixListDataBrowser selectedRowIndexes];
	
	for (i = [suffixList numSuffixes]; i >= 0; i--)
	{
		if ([selectedItems containsIndex: i])
		{
			[suffixList removeSuffix: i];
			[suffixListDataBrowser reloadData];
			break;
		}
	}
	
	if ([suffixList hasAllSuffixes])
		[numSuffixesTextField setStringValue: @"All suffixes"];
	else
		[numSuffixesTextField setStringValue: [NSString stringWithFormat:@"%d suffixes", [suffixList numSuffixes]]];
}

/*****************************************
 - called when [-] button is pressed in Types List
*****************************************/

- (IBAction) removeType:(id)sender;
{
	int i;
	NSIndexSet *selectedItems = [typesListDataBrowser selectedRowIndexes];
	
	for (i = [typesList numTypes]; i >= 0; i--)
	{
		if ([selectedItems containsIndex: i])
		{
			[typesList removeType: i];
			[typesListDataBrowser reloadData];
			break;
		}
	}
	
	if ([typesList hasAllTypes])
		[numTypesTextField setStringValue: @"All file types"];
	else
		[numTypesTextField setStringValue: [NSString stringWithFormat:@"%d file types", [typesList numTypes]]];
	if ([typesList hasFolderType])
		[numTypesTextField setStringValue: [[numTypesTextField stringValue] stringByAppendingString: @" and folders"]];
}

/*****************************************
 - called when "Default" button is pressed in Types List
*****************************************/

- (IBAction) setDefaultTypes:(id)sender
{
	//default File Types
	[typesList clearList];
	[typesList addType: @"****"];
	[typesList addType: @"fold"];
	[typesListDataBrowser reloadData];
	
    if ([typesList hasAllTypes])
		[numTypesTextField setStringValue: @"All file types"];
	else
		[numTypesTextField setStringValue: [NSString stringWithFormat:@"%d file types", [typesList numTypes]]];
	if ([typesList hasFolderType])
		[numTypesTextField setStringValue: [[numTypesTextField stringValue] stringByAppendingString: @" and folders"]];
    
	//default suffixes
	[suffixList clearList];
	[suffixList addSuffix: @"*"];
	[suffixListDataBrowser reloadData];
	
	if ([suffixList hasAllSuffixes])
		[numSuffixesTextField setStringValue: @"All suffixes"];
	else
		[numSuffixesTextField setStringValue: [NSString stringWithFormat:@"%d suffixes", [suffixList numSuffixes]]];
	
	//set app function to default
	[appFunctionRadioButtons selectCellWithTag: 0];

    [self setDocIconPath: @""];
    [self setAcceptsText: NO];
    [self setAcceptsFiles: YES];
    [self setDeclareService: NO];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	int i;
	int selected = 0;
	NSIndexSet *selectedItems;
	
	if ([aNotification object] == suffixListDataBrowser || [aNotification object] == NULL)
	{
		selectedItems = [suffixListDataBrowser selectedRowIndexes];
		for (i = 0; i < [suffixList numSuffixes]; i++)
			if ([selectedItems containsIndex: i])
				selected++;
		
        [removeSuffixButton setEnabled: (selected != 0)];
	}
	if ([aNotification object] == typesListDataBrowser || [aNotification object] == NULL)
	{
		selectedItems = [typesListDataBrowser selectedRowIndexes];
		for (i = 0; i < [typesList numTypes]; i++)
			if ([selectedItems containsIndex: i])
				selected++;
		
        [removeTypeButton setEnabled: (selected != 0)];
	}
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{	
	//bundle signature or "type code" changed
	if ([aNotification object] == typeCodeTextField || [aNotification object] == NULL)
	{
		NSRange	 range = { 0, 4 };
		NSString *sig = [[aNotification object] stringValue];
		
		if ([sig length] > 4)
			[[aNotification object] setStringValue: [sig substringWithRange: range]];
		else if ([sig length] < 4)
			[[aNotification object] setTextColor: [NSColor redColor]];
		else if ([sig length] == 4)
			[[aNotification object] setTextColor: [NSColor blackColor]];
	}

	//enable/disable buttons for Edit Types window
    [addSuffixButton setEnabled: ([[suffixTextField stringValue] length] > 0)];
    [addTypeButton setEnabled: ([[typeCodeTextField stringValue] length] == 4)];
}

- (BOOL)validateMenuItem:(NSMenuItem*)anItem
{
	if (![showTypesButton isEnabled])
		return NO;
	
	if ([[anItem title] isEqualToString: @"Remove File Type"] && [typesListDataBrowser selectedRow] == -1)
		return NO;
	
	if ([[anItem title] isEqualToString: @"Remove Suffix"] && [suffixListDataBrowser selectedRow] == -1)
		return NO;
	
	return YES;
}

#pragma mark -

- (TypesList *) types
{
	return typesList;
}

- (SuffixList *) suffixes
{
	return suffixList;
}

- (BOOL)acceptsText
{
    return [acceptDroppedTextCheckbox intValue];
}

- (void)setAcceptsText: (BOOL)b
{
    [acceptDroppedTextCheckbox setIntValue: b];
}

- (BOOL)acceptsFiles
{
    return [acceptDroppedFilesCheckbox intValue];
}

- (BOOL)declareService
{
    return [acceptDroppedTextCheckbox intValue];
}

- (void)setDeclareService: (BOOL)b
{
    [declareServiceCheckbox setIntValue: b];
}


- (void)setAcceptsFiles: (BOOL)b
{
    [acceptDroppedFilesCheckbox setIntValue: b];
}

- (NSString *)role
{
	return [[appFunctionRadioButtons selectedCell] title];
}

-(void) setRole: (NSString *)role
{
	if ([role isEqualToString: @"Viewer"])
		[appFunctionRadioButtons selectCellWithTag: 0];
	else
		[appFunctionRadioButtons selectCellWithTag: 1];
}

- (UInt64)docIconSize;
{
    if ([FILEMGR fileExistsAtPath: docIconPath])
        return [PlatypusUtility fileOrFolderSize: docIconPath];
    return 0;
}

- (NSString *)docIconPath
{
    return docIconPath;
}

- (void)setDocIconPath: (NSString *)path
{
    [docIconPath release];
    docIconPath = [path retain];
    
    //set document icon to default
    NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFileType: NSFileTypeForHFSTypeCode(kGenericDocumentIcon)];

    if (![path isEqualToString: @""]) // load it from file if it's a path
        icon = [[[NSImage alloc] initWithContentsOfFile: docIconPath] autorelease];

    if (icon != nil)
        [docIconImageView setImage: icon];
}


@end
