/*
 *  MPHelperCommon.c
 *  MacPorts.Framework
 *
 *  Created by George  Armah on 7/31/08.
 *  Copyright 2008 Lafayette College. All rights reserved.
 *
 */

#include "MPHelperCommon.h"


/*
 IMPORTANT
 ---------
 This array must be exactly parallel to the kMPHelperCommandProcs array 
 in "MPHelperTool.m".
 */

const BASCommandSpec kMPHelperCommandSet[] = {

	{	kMPHelperEvaluateTclCommand,		//commandName
		kMPHelperEvaluateTclRightsName,		//rightName
		"default",							//rightDefaultRule	-- by default, you have to have admin credentials
		NULL,								//rightDescriptionKey 
		NULL		// userData ... I might use this to pass the NSError object later on
	},

	{	NULL,								//the array is null terminated
		NULL,
		NULL,
		NULL,
		NULL
	}
	
};
