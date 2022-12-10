<template>
    <Head title="tableViews" />
    <BreezeAuthenticatedLayout>
        <template #header>
            <h2 class="font-semibold text-xl text-gray-800 leading-tight">
                Tables Arrangement
            </h2>
        </template>
        <vue-basic-alert :duration="1500" :closeIn="2500" ref="alert" />
        <div class="py-12">
            <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
                <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg">
                    <div class="p-6 bg-white border-b border-gray-200">
                        <table className="table-fixed w-full">
                            <thead>
                                <tr className="bg-gray-100">
                                    <th className="px-4 py-2 w-20">suggest id</th>
                                    <th className="px-4 py-2">restaurant name</th>
                                    <th className="px-4 py-2">table name</th>
                                    <th className="px-4 py-2">number of people</th>
                                    <th className="px-4 py-2">capacity</th>
                                    <th className="px-4 py-2">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="suggest in suggests" >
                                    <td className="border px-4 py-2">{{ suggest.suggest_id }}</td>
                                    <td className="border px-4 py-2">{{ suggest.rest_id }}</td>
                                    <td className="border px-4 py-2">{{ suggest.table_no }}</td>
                                    <td className="border px-4 py-2">{{ suggest.no_of_ppl }}</td>
                                    <td className="border px-4 py-2">{{ suggest.capacity }}</td>
                                    <td className="border px-4 py-2">
                                        <button v-if="suggest.status=='PENDING'"
                                            @click="updateStatus(suggest.suggest_id,'APPROVED')"
                                            tabIndex="-1"
                                            type="button"
                                            className="px-4 py-2 text-sm text-white bg-blue-500 rounded"
                                        >
                                            Approve
                                        </button>
                                        <button
                                        @click="updateStatus(suggest.suggest_id,'REJECTED')"
                                            tabIndex="-1"
                                            type="button"
                                            className="mx-1 px-4 py-2 text-sm text-white bg-red-500 rounded"
                                        >
                                            Reject
                                        </button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </BreezeAuthenticatedLayout>
</template>

<script>
import BreezeAuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head, Link, useForm } from '@inertiajs/inertia-vue3';
import { transformVNodeArgs } from '@vue/runtime-core';
import VueBasicAlert from 'vue-basic-alert'
import * as mqtt from "mqtt/dist/mqtt.min";

export default {
    components: {
        BreezeAuthenticatedLayout,
        VueBasicAlert
    },
    data() {
        return {
            suggests: [],
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
                topic: "table/request",
                qos: 0,
                payload: '{ "msg": "test" }',
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
        }
    },
    created () {
        this.getSuggest();
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
        getSuggest(pu=false){
            this.suggests = []
            axios.get('/getSuggest').then((response)=>{
                for (let i = 0; i < response.data['suggests'].length; i++) {
                    axios.post('/getTableById',{
                            table_id:response.data['suggests'][i].table_id,
                        }).then((response_2)=>{
                            for (let j = 0; j < response_2.data['tables'].length; j++) {
                                this.suggests.push({
                                    suggest_id:response.data['suggests'][i].suggest_id,
                                    no_of_ppl:response.data['suggests'][i].no_of_ppl,
                                    status:response.data['suggests'][i].status,
                                    rest_id:response_2.data['tables'][j].rest_id,
                                    table_no:response_2.data['tables'][j].table_no,
                                    capacity:response_2.data['tables'][j].capacity,
                                    table_x:response_2.data['tables'][j].table_x,
                                    table_y:response_2.data['tables'][j].table_y,
                                    robot_id:response_2.data['tables'][j].robot_id,
                                    table_id:response.data['suggests'][i].table_id
                                });
                            }
                    });
                }
            });
        },
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
                        if(topic=="table/request"){
                            console.log(`Received message2 ${message} from topic ${topic}`);
                            setTimeout(() => this.getSuggest(true), 1500);
                        } 
                        if(topic=="table/status"){
                            if(this.receiveNews.status == "ACTIVE"){
                                setTimeout(() => this.getSuggest(), 1200);
                            }
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
        doPublish(num, top, status, table_no) { 
            console.log('test do publish');
            console.log(num);
            console.log(top);
            console.log(status);
            console.log(table_no);
            let msg = '{ "re_no":"'+num+'","status":"'+status+'","table_no":"'+table_no+'"}';
            const { topic, qos, payload } = this.publish
            this.client.publish(top, msg, { qos }, error => {
                if (error) {
                    console.log('Publish error', error)
                }
            })
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
        updateStatus(suggest_id,status){
            console.log("delete suggest_id");
            console.log(suggest_id);
            if(!this.msg){
                let no_of_ppl = 0;
                let table_id = "";
                let rest_id = "";
                let table_no = "";
                let capacity = "";
                let table_x = "";
                let table_y = "";
                let robot_id = "";
                for (let i = 0; i < this.suggests.length; i++) {
                    if(this.suggests[i].suggest_id=suggest_id){
                        no_of_ppl = this.suggests[i].no_of_ppl
                        table_id = this.suggests[i].table_id
                        rest_id = this.suggests[i].rest_id
                        table_no = this.suggests[i].table_no
                        capacity = this.suggests[i].capacity
                        table_x = this.suggests[i].table_x
                        table_y = this.suggests[i].table_y
                        robot_id = this.suggests[i].robot_id
                    }
                }
                axios.post('/updateStatus',{
                        suggest_id:suggest_id,
                        no_of_ppl:no_of_ppl,
                        status:status,
                        table_id:table_id
                    }).then((response)=>{
                        this.getSuggest();
                        this.$refs.alert
                        .showAlert(
                            'success', // There are 4 types of alert: success, info, warning, error
                            response.data['message']+status,
                            'success!', 
                            'Success 200'
                        )
                        let index = -1;
                        for (let k = 0; k < this.suggests.length; k++) {
                            if(this.suggests[k].suggest_id==suggest_id){
                                index = index + 1;
                            }
                        }
                        if (index > -1) { 
                            this.suggests.splice(index, 1);
                        }
                        if(status=="APPROVED"){
                            axios.post('/updateStatusById',{
                                table_id:table_id,
                                table_no:table_no,
                                rest_id:rest_id,
                                capacity:capacity,
                                table_x:table_x,
                                table_y:table_y,
                                status:"INACTIVE",
                                robot_id:robot_id
                            }).then((response_msg)=>{
                                this.doPublish(suggest_id.toString(),"table/response","READY",table_no);
                                console.log(response_msg)
                            });
                        }
                });
            } 
        },

    },
}
</script>