#ifndef __RTMP_H__
#define __RTMP_H__
/*
 *      Copyright (C) 2005-2008 Team XBMC
 *      http://www.xbmc.org
 *      Copyright (C) 2008-2009 Andrej Stepanchuk
 *      Copyright (C) 2009-2010 Howard Chu
 *
 *  This file is part of librtmp.
 *
 *  librtmp is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as
 *  published by the Free Software Foundation; either version 2.1,
 *  or (at your option) any later version.
 *
 *  librtmp is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with librtmp see the file COPYING.  If not, write to
 *  the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 *  Boston, MA  02110-1301, USA.
 *  http://www.gnu.org/copyleft/lgpl.html
 */

#if !defined(NO_CRYPTO) && !defined(CRYPTO)
#define CRYPTO
#endif

#include <errno.h>
#include <stdint.h>
#include <stddef.h>

#include "amf.h"

#ifdef __cplusplus
extern "C"
{
#endif

#define RTMP_LIB_VERSION	0x020300	/* 2.3 */

#define RTMP_FEATURE_HTTP	0x01
#define RTMP_FEATURE_ENC	0x02
#define RTMP_FEATURE_SSL	0x04
#define RTMP_FEATURE_MFP	0x08	/* not yet supported */
#define RTMP_FEATURE_WRITE	0x10	/* publish, not play */
#define RTMP_FEATURE_HTTP2	0x20	/* server-side rtmpt */

#define RTMP_PROTOCOL_UNDEFINED	-1
#define RTMP_PROTOCOL_RTMP      0
#define RTMP_PROTOCOL_RTMPE     RTMP_FEATURE_ENC
#define RTMP_PROTOCOL_RTMPT     RTMP_FEATURE_HTTP
#define RTMP_PROTOCOL_RTMPS     RTMP_FEATURE_SSL
#define RTMP_PROTOCOL_RTMPTE    (RTMP_FEATURE_HTTP|RTMP_FEATURE_ENC)
#define RTMP_PROTOCOL_RTMPTS    (RTMP_FEATURE_HTTP|RTMP_FEATURE_SSL)
#define RTMP_PROTOCOL_RTMFP     RTMP_FEATURE_MFP

#define RTMP_DEFAULT_CHUNKSIZE	128

/* needs to fit largest number of bytes recv() may return */
#define RTMP_BUFFER_CACHE_SIZE (16*1024)

#define	RTMP_CHANNELS	65600

  extern const char RTMPProtocolStringsLower[][7];
  extern const AVal RTMP_DefaultFlashVer;
  extern int RTMP_ctrlC;

  uint32_t RTMP_GetTime(void);

#define RTMP_PACKET_TYPE_AUDIO 0x08
#define RTMP_PACKET_TYPE_VIDEO 0x09
#define RTMP_PACKET_TYPE_INFO  0x12

#define RTMP_MAX_HEADER_SIZE 18

#define RTMP_PACKET_SIZE_LARGE    0
#define RTMP_PACKET_SIZE_MEDIUM   1
#define RTMP_PACKET_SIZE_SMALL    2
#define RTMP_PACKET_SIZE_MINIMUM  3

  typedef struct RTMPChunk
  {
    int c_headerSize;
    int c_chunkSize;
    char *c_chunk;
    char c_header[RTMP_MAX_HEADER_SIZE];
  } RTMPChunk;

  typedef struct RTMPPacket
  {
    uint8_t m_headerType;
    uint8_t m_packetType;
    uint8_t m_hasAbsTimestamp;	/* timestamp absolute or relative? */
    int m_nChannel;
    uint32_t m_nTimeStamp;	/* timestamp */
    int32_t m_nInfoField2;	/* last 4 bytes in a long header */
    uint32_t m_nBodySize;
    uint32_t m_nBytesRead;
    RTMPChunk *m_chunk;
    char *m_body;
  } RTMPPacket;

  typedef struct RTMPSockBuf
  {
    int sb_socket;
    int sb_size;		/* number of unprocessed bytes in buffer */
    char *sb_start;		/* pointer into sb_pBuffer of next byte to process */
    char sb_buf[RTMP_BUFFER_CACHE_SIZE];	/* data read from socket */
    int sb_timedout;
    void *sb_ssl;
  } RTMPSockBuf;

  void RTMPPacket_Reset(RTMPPacket *p);
  void RTMPPacket_Dump(RTMPPacket *p);
  int RTMPPacket_Alloc(RTMPPacket *p, int nSize);
  void RTMPPacket_Free(RTMPPacket *p);

#define RTMPPacket_IsReady(a)	((a)->m_nBytesRead == (a)->m_nBodySize)

  typedef struct RTMP_LNK
  {
    AVal hostname;
    AVal sockshost;

    AVal playpath0;	/* parsed from URL */
    AVal playpath;	/* passed in explicitly */
    AVal tcUrl;
    AVal swfUrl;
    AVal pageUrl;
    AVal app;
    AVal auth;
    AVal flashVer;
    AVal subscribepath;
    AVal token;
    AMFObject extras;
    int edepth;

    int seekTime;
    int stopTime;

#define RTMP_LF_AUTH	0x0001	/* using auth param */
#define RTMP_LF_LIVE	0x0002	/* stream is live */
#define RTMP_LF_SWFV	0x0004	/* do SWF verification */
#define RTMP_LF_PLST	0x0008	/* send playlist before play */
#define RTMP_LF_BUFX	0x0010	/* toggle stream on BufferEmpty msg */
#define RTMP_LF_FTCU	0x0020	/* free tcUrl on close */
    int lFlags;

    int swfAge;

    int protocol;
    int timeout;		/* connection timeout in seconds */

    unsigned short socksport;
    unsigned short port;

#ifdef CRYPTO
#define RTMP_SWF_HASHLEN	32
    void *dh;			/* for encryption */
    void *rc4keyIn;
    void *rc4keyOut;

    uint32_t SWFSize;
    uint8_t SWFHash[RTMP_SWF_HASHLEN];
    char SWFVerificationResponse[RTMP_SWF_HASHLEN+10];
#endif
  } RTMP_LNK;

  /* state for read() wrapper */
  typedef struct RTMP_READ
  {
    char *buf;
    char *bufpos;
    unsigned int buflen;
    uint32_t timestamp;
    uint8_t dataType;
    uint8_t flags;
#define RTMP_READ_HEADER	0x01
#define RTMP_READ_RESUME	0x02
#define RTMP_READ_NO_IGNORE	0x04
#define RTMP_READ_GOTKF		0x08
#define RTMP_READ_GOTFLVK	0x10
#define RTMP_READ_SEEKING	0x20
    int8_t status;
#define RTMP_READ_COMPLETE	-3
#define RTMP_READ_ERROR	-2
#define RTMP_READ_EOF	-1
#define RTMP_READ_IGNORE	0

    /* if bResume == TRUE */
    uint8_t initialFrameType;
    uint32_t nResumeTS;
    char *metaHeader;
    char *initialFrame;
    uint32_t nMetaHeaderSize;
    uint32_t nInitialFrameSize;
    uint32_t nIgnoredFrameCounter;
    uint32_t nIgnoredFlvFrameCounter;
  } RTMP_READ;

  typedef struct RTMP_METHOD
  {
    AVal name;
    int num;
  } RTMP_METHOD;

  typedef struct _LoginInfo {
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

  typedef struct _TutorConsoleInfo {
    char userName[50];
    char sessionRoom[50];
    char role[20];
  } TutorConsoleInfo;

  typedef struct _UserIn {
    char *userName;
    char *publishName;
    char *role;
    int isLobbySession;
  } UserIn;

  typedef struct _Message {
    char *userTime;
    char *message;
    char *receiver;
    struct _Message *next;
  } Message;

  typedef struct _ConfirmedHelpMessage {
    char *msgId;
    int status;
  } ConfirmedHelpMessage;

  typedef struct _DisableVideo {
    char *userName;
    int disable;
  } DisableVideo;

  typedef struct _DisableChat {
    char *userName;
    int disable;
  } DisableChat;

  typedef struct _WebPointer {
    char *userName;
    int x;
    int y;
  } WebPointer;

  typedef struct _WebMouse {
    char *userName;
    int x;
    int y;
  } WebMouse;

  typedef enum _WhiteboardShape {
    WhiteboardShape_NoShape     = 0,
    WhiteboardShape_Line        = 1,
    WhiteboardShape_Rectangle,
    WhiteboardShape_Circle,
    WhiteboardShape_Triangle,
    WhiteboardShape_Freehand    = 6,
    WhiteboardShape_Text,
    WhiteboardShape_Image       = 10,
    WhiteboardShape_Marker
  } WhiteboardShape;

  typedef struct _WhiteboardObject {
    int objId;
    WhiteboardShape shape;
    int propertyNum;
    int propertyId[12];
    AMFObjectProperty properties[12];
  } WhiteboardObject;

  typedef struct _WhiteboardNewObjectId {
    char *addWbObjecCommand;
    int objId;
  } WhiteboardNewObjectId;

  typedef enum _RtmpCallbackType {
    RtmpCallbackType_Connected,
    RtmpCallbackType_AnchorChanged,
    RtmpCallbackType_UserIn,
    RtmpCallbackType_UserOut,
    RtmpCallbackType_Message,
    RtmpCallbackType_PlaySessionStart10MinMusic,
    RtmpCallbackType_PlaySessionStart3MinMusic,
    RtmpCallbackType_PlaySessionStartNowMusic,
    RtmpCallbackType_PlaySessionEndMusic,
    RtmpCallbackType_ClapHandsFromSrvr,
    RtmpCallbackType_ConsultantLostFromSvr,
    RtmpCallbackType_SendWaitMsgFromSrvr,
    RtmpCallbackType_NoSpeakFromSrvr,
    RtmpCallbackType_SpeakFromSrvr,
    RtmpCallbackType_SetSpkrVolFromSrvr,
    RtmpCallbackType_SetMicGainFromSrvr,
    RtmpCallbackType_DisableVideoFromSrv,
    RtmpCallbackType_DisableChatFromSrv,
    RtmpCallbackType_HelpMsgConfirmFromSrvr,
    RtmpCallbackType_ReloginFromSrvr,
    RtmpCallbackType_OnAdminMessage,
    RtmpCallbackType_Whiteboard_CurrentPage,
    RtmpCallbackType_Whiteboard_TotalPages,
    RtmpCallbackType_ResetWebPointerFromSrvr,
    RtmpCallbackType_ResetWebMouseFromSrvr,
    RtmpCallbackType_WebPointerFromSrvr,
    RtmpCallbackType_WebMouseFromSrvr,
    RtmpCallbackType_Whiteboard_ObjectChange,
    RtmpCallbackType_Whiteboard_ObjectRemove,
    RtmpCallbackType_ExitApp,
    RtmpCallbackType_Whiteboard_NewObjectId,    // server calls back the new object id after client adds a new object
    RtmpCallbackType_Whiteboard_EditMode,
  } RtmpCallbackType;

  typedef void (*RTMP_Callback)(RtmpCallbackType cbType, void *userData, void*cbData);

  typedef struct RTMP
  {
    int m_inChunkSize;
    int m_outChunkSize;
    int m_nBWCheckCounter;
    int m_nBytesIn;
    int m_nBytesInSent;
    int m_nBufferMS;
    int m_stream_id;		/* returned in _result from createStream */
    int m_mediaChannel;
    uint32_t m_mediaStamp;
    uint32_t m_pauseStamp;
    int m_pausing;
    int m_nServerBW;
    int m_nClientBW;
    uint8_t m_nClientBW2;
    uint8_t m_bPlaying;
    uint8_t m_bSendEncoding;
    uint8_t m_bSendCounter;

    int m_numInvokes;
    int m_numCalls;
    RTMP_METHOD *m_methodCalls;	/* remote method calls queue */

    RTMPPacket *m_vecChannelsIn[RTMP_CHANNELS];
    RTMPPacket *m_vecChannelsOut[RTMP_CHANNELS];
    int m_channelTimestamp[RTMP_CHANNELS];	/* abs timestamp of last packet */

    double m_fAudioCodecs;	/* audioCodecs for the connect packet */
    double m_fVideoCodecs;	/* videoCodecs for the connect packet */
    double m_fEncoding;		/* AMF0 or AMF3 */

    double m_fDuration;		/* duration of stream in seconds */

    int m_msgCounter;		/* RTMPT stuff */
    int m_polling;
    int m_resplen;
    int m_unackd;
    AVal m_clientID;

    RTMP_READ m_read;
    RTMPPacket m_write;
    RTMPSockBuf m_sb;
    RTMP_LNK Link;

    LoginInfo loginInfo;
    TutorConsoleInfo tutorConsoleInfo;
    int m_dataMode;
    RTMP_Callback m_cb;
    void *m_userData;
  } RTMP;

  int RTMP_ParseURL(const char *url, int *protocol, AVal *host,
		     unsigned int *port, AVal *playpath, AVal *app);

  void RTMP_ParsePlaypath(AVal *in, AVal *out);
  void RTMP_SetBufferMS(RTMP *r, int size);
  void RTMP_UpdateBufferMS(RTMP *r);

  int RTMP_SetOpt(RTMP *r, const AVal *opt, AVal *arg);
  int RTMP_SetupURL(RTMP *r, char *url);
  void RTMP_SetupStream(RTMP *r, int protocol,
			AVal *hostname,
			unsigned int port,
			AVal *sockshost,
			AVal *playpath,
			AVal *tcUrl,
			AVal *swfUrl,
			AVal *pageUrl,
			AVal *app,
			AVal *auth,
			AVal *swfSHA256Hash,
			uint32_t swfSize,
			AVal *flashVer,
			AVal *subscribepath,
			int dStart,
			int dStop, int bLiveStream, long int timeout);

  int RTMP_Connect(RTMP *r, RTMPPacket *cp);
  struct sockaddr;
  int RTMP_Connect0(RTMP *r, struct sockaddr *svc);
  int RTMP_Connect1(RTMP *r, RTMPPacket *cp);
  int RTMP_Serve(RTMP *r);

  int RTMP_ReadPacket(RTMP *r, RTMPPacket *packet);
  int RTMP_SendPacket(RTMP *r, RTMPPacket *packet, int queue);
  int RTMP_SendChunk(RTMP *r, RTMPChunk *chunk);
  int RTMP_IsConnected(RTMP *r);
  int RTMP_Socket(RTMP *r);
  int RTMP_IsTimedout(RTMP *r);
  double RTMP_GetDuration(RTMP *r);
  int RTMP_ToggleStream(RTMP *r);

  int RTMP_ConnectStream(RTMP *r, int seekTime);
  int RTMP_ReconnectStream(RTMP *r, int seekTime);
  void RTMP_DeleteStream(RTMP *r);
  int RTMP_GetNextMediaPacket(RTMP *r, RTMPPacket *packet);
  int RTMP_ClientPacket(RTMP *r, RTMPPacket *packet);

  void RTMP_Init(RTMP *r);
  void RTMP_Close(RTMP *r);
  RTMP *RTMP_Alloc(void);
  void RTMP_Free(RTMP *r);
  void RTMP_EnableWrite(RTMP *r);

  int RTMP_LibVersion(void);
  void RTMP_UserInterrupt(void);	/* user typed Ctrl-C */

  int RTMP_SendCtrl(RTMP *r, short nType, unsigned int nObject,
		     unsigned int nTime);

  /* caller probably doesn't know current timestamp, should
   * just use RTMP_Pause instead
   */
  int RTMP_SendPause(RTMP *r, int DoPause, int dTime);
  int RTMP_Pause(RTMP *r, int DoPause);

  int RTMP_FindFirstMatchingProperty(AMFObject *obj, const AVal *name,
				      AMFObjectProperty * p);

  int RTMPSockBuf_Fill(RTMPSockBuf *sb);
  int RTMPSockBuf_Send(RTMPSockBuf *sb, const char *buf, int len);
  int RTMPSockBuf_Close(RTMPSockBuf *sb);

  int RTMP_SendCreateStream(RTMP *r);
  int RTMP_SendSeek(RTMP *r, int dTime);
  int RTMP_SendServerBW(RTMP *r);
  int RTMP_SendClientBW(RTMP *r);
  void RTMP_DropRequest(RTMP *r, int i, int freeit);
  int RTMP_Read(RTMP *r, char *buf, int size);
  int RTMP_Write(RTMP *r, const char *buf, int size);

  void RTMP_SetCallback(RTMP *r, RTMP_Callback cb, void *userData);
  void RTMP_EnableDataMode(RTMP *r);
  int RTMP_SendConnectSharedObject(RTMP *r, const char *name, int flag);
  int RTMP_SendDisconnectSharedObject(RTMP *r, const char *name, int flag);

  typedef struct _SendMsg {   // userdata for RTMP_INVOKE_CMD_SEND_MSG
    char msg[1024];
    char username[50];
    char senderLabel[50];
    char receiver[50];
    char receiverLabel[50];
  } SendMsg;

  typedef struct _ConsultantMsg {   // userdata for RTMP_INVOKE_CMD_TALK_TO_CONSULTANT
    char username[50];
    char msgIndex[5];   // start from 1
  } ConsultantMsg;

  typedef struct _CustSuptMsg {   // userdata for RTMP_INVOKE_CMD_TALK_TO_CUSTSUPT
    char msg[1024];
    char custSuptLabel[50];
    char custSuptReceiver[50];
    char custSuptReceiverLabel[50];
    char currentClassRoom[50];
    int custSupChat;
    int custSupType;
    int custSupMsgIndex;
    char custSuptNewMsgId[20];
    char clientStatus[10];
    char compStatusLogo[10];
  } CustSuptMsg;

  typedef struct _SpkrVol {     // userdata for RTMP_INVOKE_CMD_SET_SPEAKER_VOL
    char username[50];
    int vol;
  } SpkrVol;

  typedef struct _MicGain {     // userdata for RTMP_INVOKE_CMD_SET_MIC_GAIN
    char username[50];
    int gain;
    int type; // 1: gain, 2: mute
  } MicGain;

  typedef struct _MicMute {     // userdata for RTMP_INVOKE_CMD_SET_MIC_MUTE
    char username[50];
    int mute;
  } MicMute;

  typedef struct _SysInfo {     // userdata for RTMP_INVOKE_CMD_SET_SYS_INFO
    char username[50];
    char info[50];
  } SysInfo;

  typedef struct _WbEvent {
    char event[50];
    char shape[10];
    int dataLen;
    char data[4078];    // 4096 - RTMP_MAX_HEADER_SIZE
  } WbEvent;

  typedef enum _RTMP_INVOKE_CMD {
    RTMP_INVOKE_CMD_GET_ANCHOR,
    RTMP_INVOKE_CMD_SEND_MSG,
    RTMP_INVOKE_CMD_CLAP_HANDS,
    RTMP_INVOKE_CMD_GET_CHAT_HISTORY,
    RTMP_INVOKE_CMD_TALK_TO_CONSULTANT,
    RTMP_INVOKE_CMD_TALK_TO_CUSTSUPT,
    RTMP_INVOKE_CMD_FROM_STRING,
    RTMP_INVOKE_CMD_SET_SPEAKER_VOL,
    RTMP_INVOKE_CMD_SET_MIC_GAIN,
    RTMP_INVOKE_CMD_SET_MIC_MUTE,
    RTMP_INVOKE_CMD_SET_SYS_INFO,
    RTMP_INVOKE_CMD_SEND_LOGIN_EVENT,
    RTMP_INVOKE_CMD_SEND_LOGOUT_EVENT,
    RTMP_INVOKE_CMD_SEND_WHITEBOARD_EVENT,
  } RTMP_INVOKE_CMD;
  int RTMP_InvokeCmd(RTMP *r, RTMP_INVOKE_CMD cmd, void *userdata);

/* hashswf.c */
  int RTMP_HashSWF(const char *url, unsigned int *size, unsigned char *hash,
		   int age);

#ifdef __cplusplus
};
#endif

#endif
