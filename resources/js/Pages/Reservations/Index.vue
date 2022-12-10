<template>
    <vue-basic-alert :duration="500" :closeIn="8000" ref="alert" />
    <div class="container">
        <select id="dropdown" style="margin-top:20%" @change="onChange($event.target.value)">
            <option value="Please select restaurant" selected>Please select restaurant</option>
            <option v-for="item in arrayOfObjects" :value="item.name">{{item.name}}</option>
        </select>
        <div class="form-group mt-5">
            <label for="txtBox">
            <h5>Please input the number of guest.</h5>
            </label>
            <input
                type="text"
                class="form-control"
                v-model="value"
                id="txtBox"
                placeholder="Press any button"
            />
        </div>
        <Keyboard @pressed="value = $event;doPublish($event);" :selfValue="value"></Keyboard>
    </div>
</template>

<script>
import Keyboard from '@/Components/Keyboard.vue';
import VueBasicAlert from 'vue-basic-alert'
import * as mqtt from "mqtt/dist/mqtt.min";

export default {
    components: { 
        Keyboard,
        VueBasicAlert
    },
    data() {
        return {
            arrayOfObjects: [],
            value: [],
            valueLists:[],
            rest_id: '',
            connection: {
                    protocol: "ws",
                    host: "demo.dkproject.store",
                    // ws: 1883; wss: 8084
                    port: 9001,
                    endpoint: "",
                    clean: true,
                    connectTimeout: 30 * 1000, // ms
                    reconnectPeriod: 4000, // ms
                    clientId: "emqx_vue_" + Math.random().toString(16).substring(2, 8),
                    // auth
                    username: "danielkeung",
                    password: "danielkeung123",
                    },
                subscription: {
                    topic: "table/response",
                    qos: 0,
                },
                publish: {
                    topic: "table/request",
                    qos: 0,
                    payload: '',
                },
                receiveNews: "",
                qosList: [0, 1, 2],
                client: {
                    connected: false,
                },
                subscribeSuccess: false,
                connecting: false,
                retryTimes: 0
        };
    },
    unmounted () {
        console.log('unmounted');
        this.doUnSubscribe(this.subscription);
    },
    mounted () {
        console.log('mounted');
        this.initData();
        this.createConnection();
        this.doSubscribe(this.subscription);
    },
    created () {
        axios.get('/getRest').then((response)=>{
            for (let i = 0; i < response.data['rests'].length; i++) {
                console.log(response.data['rests'][i].rest_id);
                this.arrayOfObjects.push({name:response.data['rests'][i].rest_id});
            }
            console.log(this.arrayOfObjects);
        });
    },
    methods: {
        initData() {
            this.client = {
                connected: false,
            };
            this.retryTimes = 0;
            this.connecting = false;
            this.subscribeSuccess = false;
        },
        onChange(payload) {
            document.getElementById("dropdown").disabled = true;
            this.rest_id = payload
        },
        handleOnReConnect() {
            this.retryTimes += 1;
            if (this.retryTimes > 5) {
                try {
                    this.client.end();
                    this.initData();
                    this.$message.error("Connection maxReconnectTimes limit, stop retry");
                } catch (error) {
                    this.$message.error(error.toString());
                }
            }
        },
        createConnection() {
            try {
                this.connecting = true;
                const { protocol, host, port, endpoint, ...options } = this.connection;
                const connectUrl = `${protocol}://${host}:${port}${endpoint}`;
                this.client = mqtt.connect(connectUrl, options);
                if (this.client.on) {
                    this.client.on("connect", () => {
                        this.connecting = false;
                        this.client.connected = true;
                        console.log("Connection succeeded!");
                    });
                    this.client.on("reconnect", this.handleOnReConnect);
                    this.client.on("error", (error) => {
                        console.log("Connection failed", error);
                    });
                    this.client.on("message", (topic, message) => {
                        console.log(`Received message ${message} from topic ${topic}`);
                        this.receiveNews = "";
                        this.receiveNews = JSON.parse(this.receiveNews.concat(message));
                        if(topic=="table/response"){
                            let alert_msg = "";
                            if(this.receiveNews['status']=="READY"){
                                alert_msg = this.receiveNews['re_no']+" is Ready. Your table no is "+this.receiveNews['table_no']+". ";
                            }
                            if(this.receiveNews['status']=="PENDING"){
                                alert_msg = "Your reservation no. is "+this.receiveNews['re_no'];
                            }
                            this.$refs.alert
                            .showAlert(
                                "success",
                                alert_msg,
                                'Information!', 
                                '',
                                { 
                                    iconSize: 500, 
                                    iconType: 'solid', 
                                    position: 'top left' 
                                }
                            )
                        }
                    });
                }
            } catch (error) {
                this.connecting = false;
                console.log('createConnection error');
                this.handleOnReConnect();
                console.log("mqtt.connect error", error);
            }
        },
        doPublish(val) {
            if(val=="enter"){
                if(this.valueLists.length>0){
                    let no_ppl = this.valueLists[this.valueLists.length-1]
                    if(this.rest_id){
                        let msg = '{ "no_of_ppl":'+no_ppl+',"rest_id":"'+this.rest_id+'"}';
                        const { topic, qos, payload } = this.publish
                        this.client.publish(topic, msg, { qos }, error => {
                            this.valueLists = [];
                            if (error) {
                                console.log('Publish error', error)
                            }
                        })
                    } else{
                        this.$refs.alert
                        .showAlert(
                            'error', // There are 4 types of alert: success, info, warning, error
                            "Please select the restaurant.",
                            'Error!', 
                            'Error 404',
                            { 
                                iconSize: 100, 
                                iconType: 'solid', 
                                position: 'top left' 
                            }
                        )
                    }
                }
                this.value = "";
            } else {
                this.valueLists.push(val);
            }
        },
        doSubscribe(subscription) {
            const { topic, qos } = subscription
            this.client.subscribe(topic, { qos }, (error, res) => {
                if (error) {
                    console.log('Subscribe to topics error', error)
                    return
                }
                this.subscribeSuccess = true
                console.log('Subscribe to topics res', res)
            })
        },
        doUnSubscribe(subscription) {
            const { topic } = subscription
            console.log('doUnSubscribe');
            this.client.unsubscribe(topic, error => {
                if (error) {
                    console.log('Unsubscribe error', error)
                }
            })
        },
        destroyConnection() {
            if (this.client.connected) {
                try {
                    this.client.end(false, () => {
                        this.initData()
                        console.log('Successfully disconnected!')
                    })
                } catch (error) {
                    console.log('Disconnect failed', error.toString())
                }
            }
        },
    }
};
</script>

<style scoped>
.container {
    max-width: 300px;
}
</style>