/**
 * Copyright (c) 2016, Simone Donetti. All rights reserved. 
 * This file is licensed under the terms of the ISC License.
 *
 * For more information related to the use of jolie for receiving post and get
 * operation please have a look at Jolie online documentation:
 * http://docs.jolie-lang.org/#!documentation/web_applications/web_get_post.html
 */

include "console.iol"
include "exec.iol"
include "math.iol"
include "file.iol"
include "string_utils.iol"
include "json_utils.iol"
include "converter.iol"
include "time.iol"
include "runtime.iol"


type LogRequest: void{
	.filename: string
	.append?: int
	.content: string
}


// execution is concurrent: more than one instance can be run at the same time
execution { concurrent }

interface HyVarInterface {
RequestResponse:
	
	// operation to get the statechart file
	// the input and output are json object (undefined type for jolie)
  receiveTUB( undefined )( undefined ),
	
	// Test for connection timeout
  timeout( void )( undefined ),
	// operation to check if the service is still alive and responding
  health( void )( void )
}

inputPort ReconfiguratorService {
		// locally the server will be expecting request on port 8080
    Location: "socket://localhost:8080/"
		// the protocol used is http and the data send and receive follow json format
    Protocol: http { .format = "json"; .json_encoding = "strict" }
		// the server implements the HyVarRecInterface interface
    Interfaces: HyVarInterface
}

interface LocalInterface {
RequestResponse:
  saveLog( LogRequest )( void )
}

outputPort Self {
    Interfaces: LocalInterface
}

inputPort Self {
    Location: "local"
    Interfaces: LocalInterface
}

init
{
	getLocalLocation@Runtime()( Self.location )
}

// JAXRS-RESTEasy/rest/rest/
/* The program waits for a request and process it.
The operation can be process or health
*/

main {
	[ receiveTUB( request )( response ) {
		// Define the working directory
		test = true;
		while( test ) {
			random@Math()(num);
			createDir = ""+string(num)+"Compile";
			baseWorkingDir = "/home/hyvar/work/"+createDir+"/";
			exists@File( baseWorkingDir )( test )
		};
		mkdir@File( baseWorkingDir )( test );

		CurrentDateTimeRequestType.format = "yyyy-MM-dd_HH-mm-ss";
		getCurrentDateTime@Time( CurrentDateTimeRequestType )( str );
		logFileRequest.filename = "/home/hyvar/logs/receiveTUB_"+str+"_"+createDir+".log";
		logFileRequest.append = 1;

		logFileRequest.content = "Received TUB request.";
		saveLog@Self(logFileRequest)();

		// Convert JSON representation into string
		getJsonString@JsonUtils(request)(json_string);

		
		// Duplicate the source directory
		logFileRequest.content = "Duplicate the source directory.";
		saveLog@Self(logFileRequest)();
		copy_dir_rerquest.from = "/home/hyvar/source";
		copy_dir_rerquest.to = baseWorkingDir;
		copyDir@File(copy_dir_rerquest)(result);
		

		// Save the JSON input data
		logFileRequest.content = "Save the JSON input data.";
		saveLog@Self(logFileRequest)();
		json_input_file = baseWorkingDir + "backup/data_in.json";
		write_file_request.content = json_string;
		write_file_request.filename = json_input_file;
		writeFile@File(write_file_request)();

		// Extract the files from input JSON message
		logFileRequest.content = "Extract the files from input JSON message.";
		saveLog@Self(logFileRequest)();
		getJsonValue@JsonUtils(json_string)(json_value);
		logFileRequest.content = "Total recived file: "+ #json_value.("statechartVariants");
		saveLog@Self(logFileRequest)();

		for ( i=0, i< #json_value.("statechartVariants"), i++ ) {
			logFileRequest.content = "Element: "+ json_value.("statechartVariants")[i].("name");
			saveLog@Self(logFileRequest)();

			file_name = baseWorkingDir + "input/"+json_value.("statechartVariants")[i].("name");
			write_file_name.content = json_value.("statechartVariants")[i].("content");
			write_file_name.filename = file_name;
			writeFile@File(write_file_name)()

		};
		
		//Duplicate statechart into project directory
		logFileRequest.content = "Headless code generation.";
		saveLog@Self(logFileRequest)();
		//str_output += "Headless code generation. \n";
		command_request = "sh";
		command_request.args[0] = "invoke_logic.sh";
		command_request.workingDirectory = baseWorkingDir;
		command_request.stdOutConsoleEnable = true;
		exec@Exec( command_request )( output );
		logFileRequest.content = "Headless code generation done...";
		saveLog@Self(logFileRequest)();
		//str_output += output;
	   	
		logFileRequest.content = "Code generation output.... \n"+output;
		saveLog@Self(logFileRequest)();
		logFileRequest.content = "stdError: "+output.stderr;
		saveLog@Self(logFileRequest)();
		logFileRequest.content = "Exit code: "+output.exitCode;
		saveLog@Self(logFileRequest)();
	
		logFileRequest.content = "Done!";
		saveLog@Self(logFileRequest)();

		


		// Create the output json message
		str_output = "{\"msg_type\":\"compiled jar\",";
		ListRequest.directory = baseWorkingDir+"output";
		list@File(ListRequest)(elenco);
		fileFound=false;
		for ( j=0, j< #elenco.result, j++ ) {
			if(fileFound) {
				str_output = str_output+","
			} else {
				fileFound=true
			};
			logFileRequest.content = "- "+j+": "+ elenco.result[j];
			saveLog@Self(logFileRequest)();
			str_output = str_output+"\"file\":\"/home/output/"+elenco.result[j]+"\",";
			str_output = str_output+"\"content\":\"";

			ReadFileRequest.filename = baseWorkingDir+"output/"+elenco.result[j];
			ReadFileRequest.format = "base64";
			readFile@File(ReadFileRequest)(rawData);
			//rawToBase64(rawData)(encodedFile);
			str_output = str_output+rawData;

			str_output = str_output+"\""
		};
		str_output = str_output+"}";

		// Remove the working directory
		logFileRequest.content = "Remove the working directory";
		saveLog@Self(logFileRequest)();
		//deleteDir@File(baseWorkingDir)();

		logFileRequest.content = "Done!";
		saveLog@Self(logFileRequest)();

		// Convert response into json
		getJsonValue@JsonUtils(str_output)(response)
	} ] {nullProcess}



	// Test for connection timeout
	[ timeout( request )( response ) {
		CurrentDateTimeRequestType.format = "yyyy-MM-dd_HH-mm-ss";
		getCurrentDateTime@Time( CurrentDateTimeRequestType )( str );
		logFileRequest.filename = "/home/hyvar/logs/timeout_"+str+".log";
		logFileRequest.append = 1;

		logFileRequest.content = "Time service.";
		saveLog@Self(logFileRequest)();

		str_output = "{\"msg_type\":\"timeout-test\",";
		str_output += "\"output\":\"Time service \n";

		logFileRequest.content = "Running sleep.";
		saveLog@Self(logFileRequest)();

		str_output += "Running sleep. \n";
		command_request = "sh";
		command_request.args[0] = "sleepTest.sh";
		command_request.workingDirectory = "/home/hyvar/";
		command_request.stdOutConsoleEnable = false;
		exec@Exec( command_request )( output );
		str_output += output;

		logFileRequest.content = output;
		saveLog@Self(logFileRequest)();

		logFileRequest.content = "Done!";
		saveLog@Self(logFileRequest)();

		str_output += "Done! \n";

		str_output += "\"}";
		getJsonValue@JsonUtils(str_output)(response)
	} ] {nullProcess}


	// the health process does not do anything except an
	[ health( request )( response ) ] { nullProcess }


	// Print on console and save the log on file
	[ saveLog( LogRequest )( void ) {
		println@Console( LogRequest.content )();
		LogRequest.content += "\n";
		writeFile@File(LogRequest)()
	} ] { nullProcess }

}

