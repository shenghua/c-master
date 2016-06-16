/**
 * @file
 * RTMP protocol backdoor handler
 */

#ifndef AVFORMAT_RTMPPROTO_BACKDOOR_H
#define AVFORMAT_RTMPPROTO_BACKDOOR_H

/** RTMP protocol backdoor command */
typedef enum {
    RTMP_BACKDOOR_CMD_GET_WRITE_THROUGHPUT,
    RTMP_BACKDOOR_CMD_INVOKE_RPC,
    RTMP_BACKDOOR_CMD_GET_STREAM_INFO,
    RTMP_BACKDOOR_CMD_SET_SERVER_NOTIFY_CALLBACK,
} RTMP_BACKDOOR_CMD;

// RTMP command struct
typedef struct GetWriteThroughputContext {
    float	writeThroughput;
} GetWriteThroughputContext;

typedef struct InvokeRpcContext {
    char	methodName[256];
} InvokeRpcContext;

typedef struct GetStreamInfoContext {
	uint8_t	firstAudioData[10240];
	int 	firstAudioDataLen;
	uint8_t	firstVideoData[102400];
	int 	firstVideoDataLen;
} GetStreamInfoContext;

typedef enum _ServerNotify {
    ServerNotify_onTimeCodeEvent,
    ServerNotify_onCuePointEvent,
    ServerNotify_onInsufficientBW,
} ServerNotify;

typedef struct SetServerNotifyCallback {
	void *serverNotifyUserData;
	void (*serverNotifyCallback)(void *userData, ServerNotify notify, void *notifyData);
} SetServerNotifyCallback;

#endif /* AVFORMAT_RTMPPROTO_BACKDOOR_H */
