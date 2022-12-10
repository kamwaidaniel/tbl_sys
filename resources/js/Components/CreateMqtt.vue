
<script>
import * as mqtt from "mqtt/dist/mqtt.min"; 

export default {
    components: {
        
    },
    data() {
        return {
            connection: {
                protocol: "ws",
                host: "demo.dkproject.store",
                // ws: 1883; wss: 8084
                port: 9001,
                endpoint: "",
                // for more options, please refer to https://github.com/mqttjs/MQTT.js#mqttclientstreambuilder-options
                clean: true,
                connectTimeout: 30 * 1000, // ms
                reconnectPeriod: 4000, // ms
                clientId: "emqx_vue_" + Math.random().toString(16).substring(2, 8),
                // auth
                username: "danielkeung",
                password: "danielkeung123",
                },
            subscription: {
                topic: "table/request",
                qos: 0,
            },
            subscription2: {
                topic: "table/status",
                qos: 0,
            },
            publish: {
                topic: "table/response",
                qos: 0,
                payload: '',
            },
            publish2: {
                topic: "table/status",
                qos: 0,
                payload: '{ "msg": "test" }',
            },
            receiveNews: "",
            qosList: [0, 1, 2],
            client: {
                connected: false,
            },
            subscribeSuccess: false,
            connecting: false,
            retryTimes: 0,
            InfoListTmp2: [],
        }
    },
    unmounted () {
        console.log('unmounted');
        this.doUnSubscribe(this.subscription);
        this.doUnSubscribe(this.subscription2);
    },
    mounted () {
        console.log('mounted');
        this.initData();
        this.createConnection();
        this.doSubscribe(this.subscription);
        this.doSubscribe(this.subscription2);
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
                        this.receiveNews = "";
                        this.receiveNews = JSON.parse(this.receiveNews.concat(message));
                        console.log(`Received message ${message} from topic ${topic}`);
                        if(topic=="table/request"){
                            axios.post('/productSuggest',{
                                no_of_ppl:this.receiveNews.no_of_ppl,
                                rest_id:this.receiveNews.rest_id
                            }).then((response)=>{
                                this.getSuggest(true)
                            });
                        }
                        if(topic=="table/status"){
                            axios.post('/getTableByRestIdTableNo',{
                                table_no:this.receiveNews.table_no,
                                rest_id:this.receiveNews.rest_id
                            }).then((response)=>{
                                axios.post('/updateStatusById',{
                                    table_id: response.data['table'][0].table_id,
                                    table_no: response.data['table'][0].table_no,
                                    rest_id: response.data['table'][0].rest_id,
                                    capacity: response.data['table'][0].capacity,
                                    table_x: response.data['table'][0].table_x,
                                    table_y: response.data['table'][0].table_y,
                                    status: this.receiveNews.status,
                                    robot_id: response.data['table'][0].robot_id
                                }).then((response_msg)=>{
                                        console.log(response_msg);
                                        this.InfoListTmp2.push({
                                        table_id: response.data['table'][0].table_id,
                                        table_no: response.data['table'][0].table_no,
                                        rest_id: response.data['table'][0].rest_id,
                                        capacity: response.data['table'][0].capacity,
                                        table_x: response.data['table'][0].table_x,
                                        table_y: response.data['table'][0].table_y,
                                        status: this.receiveNews.status,
                                        robot_id: response.data['table'][0].robot_id
                                    });
                                });
                                if(this.receiveNews.status=="ACTIVE"){
                                    axios.post('/getSuggestByTableId',{
                                        table_id: response.data['table'][0].table_id
                                    }).then((response_s)=>{
                                        response_s.data['suggest'][0]
                                        axios.post('/updateStatus',{
                                            suggest_id:response_s.data['suggest'][0].suggest_id,
                                            no_of_ppl:response_s.data['suggest'][0].no_of_ppl,
                                            status:"PENDING",
                                            table_id:response_s.data['suggest'][0].table_id
                                        }).then((response_x)=>{console.log(response_x);});
                                    });
                                }
                            });
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
        doPublish(num, top, status, table_no) { 
            let msg = '{ "re_no":"'+num+'","status":"'+status+'","table_no":"'+table_no+'"}';
            const { topic, qos, payload } = this.publish
            this.client.publish(top, msg, { qos }, error => {
                if (error) {
                    console.log('Publish error', error)
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
        getSuggest(pu=false){
            axios.get('/getSuggest').then((response)=>{
                for (let i = 0; i < response.data['suggests'].length; i++) {
                    axios.post('/getTableById',{
                            table_id:response.data['suggests'][i].table_id,
                        }).then((response_2)=>{
                            console.log(response_2);
                    });
                    if(i==response.data['suggests'].length-1 && pu){
                        this.doPublish((response.data['suggests'][i].suggest_id).toString(),"table/response","PENDING","");
                    }
                }
            });
        },
    },
}
</script>