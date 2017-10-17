/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

var app = {
    // Application Constructor
    initialize: function() {
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },

    // deviceready Event Handler
    onDeviceReady: function() {
        /*  NOTE: On Android 6+, in order to get access to the microphone/camera,
            Runtime Permissions "RECORD_AUDIO" and "CAMERA" must be not only given
            through AndroidManifest.xml, but also manually by the User.
            Use (for instance) the plugin "cordova.plugins.diagnostic" and
            its method "requestRuntimePermissions" to proceed. */

        // Sign up for an OpenTok API Key at: https://tokbox.com/signup
        // Then generate a sessionId and token at: https://dashboard.tokbox.com
        var apiKey = ""; // INSERT YOUR API Key
        var sessionId = ""; // INSERT YOUR SESSION ID
        var token = ""; // INSERT YOUR TOKEN

        var session = TB.initSession(apiKey, sessionId, true);
        var publisher;

        session.on({
            // once the session is connected: initialize publisher & start streaming
            'sessionConnected': function(event) {
                console.log(event);
                /* Options: [
                        name, width, height, zIndex, publishAudio,
                        publishVideo, cameraName, borderRadius,
                        ratios.widthRatio, ratios.heightRatio,
                        position.top, position.left
                    ] */
                var options = {};
                publisher = TB.initPublisher('myPublisherDiv', options, function() {
                    publisher.setSession(session);
                    session.publish(publisher);
                });
            },
            // anytime a new stream is published in the session
            'streamCreated': function(event) {
                if (!publisher.stream) {
                    // ignore own/self stream (played in div 'myPublisherDiv')
                    return;
                }

                var div = document.createElement('div');
                div.setAttribute('id', 'stream' + event.stream.streamId);
                document.body.appendChild(div);
                session.subscribe(event.stream, div.id);
            }
        });

        // accept a callback as a second parameter
        session.connect(token);
    }
};
