import {
    NativeModules,
    NativeEventEmitter
} from 'react-native';

const { Qiniu } = NativeModules
const qnEmitter = new NativeEventEmitter(Qiniu);

export const QNEngine = {
    ...Qiniu,
    init(options = {}) {
        this.listener && this.listener.remove();
        Qiniu.init(options);
    },
    eventEmitter(fnConf) {
        this.removeEmitter();
        this.listener = qnEmitter.addListener(
            'qiniuEvent',
            (event) => {
                fnConf[event['type']] && fnConf[event['type']](event);
            }
        );
    },
    removeEmitter() {
        this.listener && this.listener.remove();
        this.listener = null;
    }
};