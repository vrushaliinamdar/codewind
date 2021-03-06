/*******************************************************************************
 * Licensed Materials - Property of IBM
 * "Restricted Materials of IBM"
 *
 * Copyright IBM Corp. 2018, 2019 All Rights Reserved
 *
 * US Government Users Restricted Rights - Use, duplication or disclosure
 * restricted by GSA ADP Schedule Contract with IBM Corp.
 *******************************************************************************/
/**
 * Log file conventions:
 * docker.build -> docker image build log file
 * docker.app -> docker app build log file
 * maven.build -> maven build log file
 * app.compile -> app compilation log file
 */
import { codewindTemplates, projecLanguges } from "./app.config";

export enum log_names {
    dockerBuild = "docker.build.log",
    mavenBuild = "maven.build.log",
    appCompile = "app.compile.log",
    dockerApp = "docker.app.log",
    application = "app.log",
    libertyMessages = "messages.log",
    libertyConsole = "console.log",
    odoBuild = "odo.build.log",
    odoApp = "odo.app.log"
}

export enum logTypes {
    build = "build",
    app = "app"
}

enum logOrigins {
    container = "container",
    workspace = "workspace"
}

const defaultDockerLogs = {
    [logTypes.build]: [{
        "origin": logOrigins.workspace,
        "files": [log_names.dockerBuild]
    }],
    [logTypes.app]: [{
        "origin": logOrigins.workspace,
        "files": [log_names.application]
    }]
};

const defaultODOLogs = {
    [logTypes.build]: [{
        "origin": logOrigins.workspace,
        "files": [log_names.odoBuild]
    }],
    [logTypes.app]: [{
        "origin": logOrigins.workspace,
        "files": [log_names.odoApp]
    }]
};

export const logFileMappings: any = {
    [codewindTemplates.default]: {
        [projecLanguges.liberty]: {
            [logTypes.build]: [{
                "origin": logOrigins.container,
                "files": [log_names.mavenBuild]
            }, {
                "origin": logOrigins.workspace,
                "files": [log_names.dockerBuild]
            }],
            [logTypes.app]: [{
                "origin": logOrigins.workspace,
                "files": [log_names.application]
            }, {
                "origin": logOrigins.container,
                "files": [log_names.libertyConsole, log_names.libertyMessages]
            }]
        },
        [projecLanguges.nodejs]: {
            [logTypes.build]: [{
                "origin": logOrigins.workspace,
                "files": [log_names.dockerBuild]
            }],
            [logTypes.app]: [{
                "origin": logOrigins.workspace,
                "files": [log_names.application]
            }]
        },
        [projecLanguges.spring]: {
            [logTypes.build]: [{
                "origin": logOrigins.container,
                "files": [log_names.mavenBuild]
            }, {
                "origin": logOrigins.workspace,
                "files": [log_names.dockerBuild]
            }],
            [logTypes.app]: [{
                "origin": logOrigins.workspace,
                "files": [log_names.application]
            }]
        },
        [projecLanguges.swift]: {
            [logTypes.build]: [{
                "origin": logOrigins.workspace,
                "files": process.env.IN_K8 ? [log_names.appCompile, log_names.dockerApp] : [log_names.dockerApp, log_names.appCompile, log_names.dockerBuild]
            }],
            [logTypes.app]: [{
                "origin": logOrigins.workspace,
                "files": [log_names.application]
            }]
        }
    },
    [codewindTemplates.docker]: {
        [projecLanguges.go]:  defaultDockerLogs,
        [projecLanguges.lagom]: defaultDockerLogs,
        [projecLanguges.python]: defaultDockerLogs
    },
    [codewindTemplates.odo]: {
        [projecLanguges.nodejs]: defaultODOLogs,
        [projecLanguges.perl]: defaultODOLogs,
        [projecLanguges.python]: defaultODOLogs
    },
};
