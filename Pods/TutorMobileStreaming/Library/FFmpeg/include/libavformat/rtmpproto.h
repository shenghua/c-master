/*
 * RTMP network protocol
 * Copyright (c) 2009 Konstantin Shishkov
 *
 * This file is part of FFmpeg.
 *
 * FFmpeg is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * FFmpeg is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with FFmpeg; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

/**
 * @file
 * RTMP protocol
 */

#include "rtmppkt.h"
#include "url.h"
#include "rtmpproto_backdoor.h"

#ifndef AVFORMAT_RTMPPROTO_H
#define AVFORMAT_RTMPPROTO_H

typedef struct TrackedMethod {
    char *name;
    int id;
} TrackedMethod;

/** RTMP protocol handler state */
typedef enum {
    STATE_START,      ///< client has not done anything yet
    STATE_HANDSHAKED, ///< client has performed handshake
    STATE_FCPUBLISH,  ///< client FCPublishing stream (for output)
    STATE_PLAYING,    ///< client has started receiving multimedia data from server
    STATE_SEEKING,    ///< client has started the seek operation. Back on STATE_PLAYING when the time comes
    STATE_PUBLISHING, ///< client has started sending multimedia data to server (for output)
    STATE_RECEIVING,  ///< received a publish command (for input)
    STATE_SENDING,    ///< received a play command (for output)
    STATE_STOPPED,    ///< the broadcast has been stopped
} ClientState;

#define RTMP_HEADER 11

typedef struct LoginInfo {
    int roomType;
    char userName[50];
    char recordStatus[10];
    char sessionRoomId[50];
    int  userType;
    char cname[50];
    char password[50];
    int liveDelay;      // bool
    int lobbySession;   // bool
    char camera[10];
    char rating[10];
    int glassSession;   // bool
    int closeType;
    char auth[10];
    char firstName[50];
    char streamFileFormatPrefix[50];
    char role[20];
    char sessionSn[50];
    char userSn[50];
    char email[50];
    char protocol[10];
    int commProcMode;
    char streamFileFormat[50];
    int clockStartMin;
    char compStatus[10];
} LoginInfo;

typedef struct RTMPContext {
    const AVClass *class;
    void*         server_notify_callback_userdata;
    void          (*server_notify_callback)(void *userData, ServerNotify serverNotify, void *serverNotifyData);    ///< callback notify from server
    URLContext*   stream;                     ///< TCP stream used in interactions with RTMP server
    RTMPPacket    *prev_pkt[2];               ///< packet history used when reading and sending packets ([0] for reading, [1] for writing)
    int           nb_prev_pkt[2];             ///< number of elements in prev_pkt
    int           in_chunk_size;              ///< size of the chunks incoming RTMP packets are divided into
    int           out_chunk_size;             ///< size of the chunks outgoing RTMP packets are divided into
    int           is_input;                   ///< input/output flag
    char          *playpath;                  ///< stream identifier to play (with possible "mp4:" prefix)
    int           live;                       ///< 0: recorded, -1: live, -2: both
    char          *app;                       ///< name of application
    char          *conn;                      ///< append arbitrary AMF data to the Connect message
    ClientState   state;                      ///< current state
    int           stream_id;                  ///< ID assigned by the server for the stream
    uint8_t*      flv_data;                   ///< buffer with data for demuxer
    int           flv_size;                   ///< current buffer size
    int           flv_off;                    ///< number of bytes read from current buffer
    int           flv_nb_packets;             ///< number of flv packets published
    RTMPPacket    out_pkt;                    ///< rtmp packet, created from flv a/v or metadata (for output)
    uint32_t      client_report_size;         ///< number of bytes after which client should report to server
    uint32_t      bytes_read;                 ///< number of bytes read from server
    uint32_t      last_bytes_read;            ///< number of bytes read last reported to server
    uint32_t      last_timestamp;             ///< last timestamp received in a packet
    uint32_t      pause_timestamp;            ///< timestamp set for pause
    int           skip_bytes;                 ///< number of bytes to skip from the input FLV stream in the next write call
    int           has_audio;                  ///< presence of audio data
    int           has_video;                  ///< presence of video data
    int           received_metadata;          ///< Indicates if we have received metadata about the streams
    uint8_t       flv_header[RTMP_HEADER];    ///< partial incoming flv packet header
    int           flv_header_bytes;           ///< number of initialized bytes in flv_header
    int           nb_invokes;                 ///< keeps track of invoke messages
    char*         tcurl;                      ///< url of the target stream
    char*         flashver;                   ///< version of the flash plugin
    char*         swfhash;                    ///< SHA256 hash of the decompressed SWF file (32 bytes)
    int           swfhash_len;                ///< length of the SHA256 hash
    int           swfsize;                    ///< size of the decompressed SWF file
    char*         swfurl;                     ///< url of the swf player
    char*         swfverify;                  ///< URL to player swf file, compute hash/size automatically
    char          swfverification[42];        ///< hash of the SWF verification
    char*         pageurl;                    ///< url of the web page
    char*         subscribe;                  ///< name of live stream to subscribe
    int           server_bw;                  ///< server bandwidth
    int           client_buffer_time;         ///< client buffer time in ms
    int           flush_interval;             ///< number of packets flushed in the same request (RTMPT only)
    int           encrypted;                  ///< use an encrypted connection (RTMPE only)
    TrackedMethod*tracked_methods;            ///< tracked methods buffer
    int           nb_tracked_methods;         ///< number of tracked methods
    int           tracked_methods_size;       ///< size of the tracked methods buffer
    int           listen;                     ///< listen mode flag
    int           listen_timeout;             ///< listen timeout to wait for new connections
    int           nb_streamid;                ///< The next stream id to return on createStream calls
    double        duration;                   ///< Duration of the stream in seconds as returned by the server (only valid if non-zero)
    char          username[50];
    char          password[50];
    char          auth_params[500];
    int           do_reconnect;
    int           auth_tried;
    int           receivevideo;               ///< Receive video data or not. 0: no, 1: yes.
    int           receiveaudio;               ///< Receive audio data or not. 0: no, 1: yes.
    uint8_t       firstAudioData[10240];       ///< the first audio data
    int           firstAudioDataLen;          ///< the length of the first audio data
    uint8_t       firstVideoData[102400];       ///< the first video data
    int           firstVideoDataLen;          ///< the length of the first video data
    int           glass_so;
    int           users_so;
    int           webinar_users_so;
    void          (*so_callback)(int, char*);                   ///< function of JNI shared object callback(int data_size, char* data_payload) 
    void          (*cmd_callback)(const char*, int, char*);     ///< function of JNI invoke command callback(const char* method_name, int data_size, char* data_payload)
    LoginInfo     loginInfo;                  ///< loign info for passing to server when connecting
    int           hasLoginInfo;

} RTMPContext;

#endif /* AVFORMAT_RTMPPROTO_H */