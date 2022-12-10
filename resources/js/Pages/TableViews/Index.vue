<template>
    <Head title="Dashboard" />
    <BreezeAuthenticatedLayout>
        <template #header>
            <h2 class="font-semibold text-xl text-gray-800 leading-tight">
                The overview of the Restaurant
            </h2>
        </template>
        <div class="py-12">
            <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
                <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg">
                    <div class="p-6 bg-white border-b border-gray-200">
                        <div className="flex items-center justify-between mb-6">
                            restaurant name
                        </div>
                        <div className="flex items-center justify-between mb-6">
                            <dropdown class="my-dropdown-toggle"
                                    :options="arrayOfObjects" 
                                    :selected="{name:'tst001'}" 
                                    v-on:updateOption="methodToRunOnSelect" 
                                    :closeOnOutsideClick="boolean">
                            </dropdown>
                        </div>
                        <div >
                            <div class="drag">
                                <div>
                                    <div id="movearea" v-if="show_move_area" :style="{width:rest_x+'px',height:rest_y+'px'}" @drop.prevent="drop" @dragover.prevent ref="moveArea" class="move-area">
                                        <div id="table-info" v-for="(info, index) in InfoList" :key="index">
                                            <div v-if="info.status=='ACTIVE'">
                                                <Popper arrow :content="'Table name: '+info.id+'\n'
                                                                        +'Capacity: '+info.capacity+'\n'
                                                                        +'Status: '+info.status+'\n'
                                                                        +'Robot id: '+info.robot_id
                                                                        " 
                                                :style="{left:info.x+'px',top:info.y+'px'}">
                                                    <button v-on:click="redirect_to_login">
                                                        <img
                                                            class="img1"
                                                            src="@/img/green_table.png"
                                                            :id="info.id"
                                                            :key="index"
                                                            v-on:dblclick="showPopUp(info.id)"
                                                        />
                                                    </button>
                                                </Popper>
                                            </div>
                                            <div v-else>
                                                <Popper arrow :content="'Table name: '+info.id+'\n'
                                                                        +'Capacity: '+info.capacity+'\n'
                                                                        +'Status: '+info.status+'\n'
                                                                        +'Robot id: '+info.robot_id
                                                                        " 
                                                :style="{left:info.x+'px',top:info.y+'px'}">
                                                    <button v-on:click="redirect_to_login">
                                                        <img
                                                            class="img1"
                                                            src="@/img/red_table.png"
                                                            :id="info.id"
                                                            :key="index"
                                                            v-on:dblclick="showPopUp(info.id)"
                                                        />
                                                    </button>
                                                </Popper>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div className="flex items-center justify-between mb-6" :style="{'margin-top':(buttonTop+height)+'px'}">
                            <img
                                src="@/img/red_table.png"
                                class="img1"
                            /> 
                        </div>
                        <BreezeLabel value="unavailable" />
                        <div className="flex items-center justify-between mb-6 " :style="{'margin-top':'50px'}">
                            <img
                                src="@/img/green_table.png"
                                class="img1"
                            /> 
                        </div>
                        <BreezeLabel value="available" />
                    </div>
                </div>
            </div>
        </div>
    </BreezeAuthenticatedLayout>
</template>

<script>
import BreezeAuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import BreezeLabel from '@/Components/InputLabel.vue';
import BreezeInput from '@/Components/TextInput.vue';
import { Head, Link, useForm } from '@inertiajs/inertia-vue3';
import { Modal } from 'usemodal-vue3';
import { transformVNodeArgs } from '@vue/runtime-core';
import dropdown from 'vue-dropdowns';
import Popper from "vue3-popper";
import * as mqtt from "mqtt/dist/mqtt.min"; 

export default {
    components: {
        BreezeAuthenticatedLayout,
        BreezeLabel,
        BreezeInput,
        Modal,
        'dropdown': dropdown,
        "Popper": Popper,
    },
    data() {
        return {
            tags: [1, 2, 3],
            InfoList: [],
            restList: [],
            rest_id:"",
            rest_x:"",
            rest_y:"",
            height:0,
            show_move_area: false,
            offTop:0,
            offTop:0,
            isVisible:false,
            capacity:0,
            robot_id:"",
            counter:1,
            buttonTop:120,
            buttonTop2:150,
            editingTableId:"",
            msg:"",
            isExist:false,
            arrayOfObjects: [],
            selectedObj: {
                name: '',
            },
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
    created () {
        console.log("tets1");
        axios.get('/getRest').then((response)=>{
                this.restList = response.data['rests'];
                for (let i = 0; i < this.restList.length; i++) {
                    this.arrayOfObjects.push({name:this.restList[i].rest_id});
                }
                this.selectedObj.name = this.restList[0].rest_id;
                this.rest_id = this.restList[0].rest_id
                this.check_rest();
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
                        if(topic=="table/status"){
                            console.log(`Received message ${message} from topic ${topic}`);
                            setTimeout(() => this.check_rest(), 2000);
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
        assignValueToInfoList(table_no,x,y,capacity,robot_id,status){
            for (let i = 0; i < this.InfoList.length; i++) {
                if(this.InfoList[i].id==table_no){
                    if(x){
                        this.InfoList[i].x = x;
                    }
                    if(y){
                        this.InfoList[i].y = y;
                    }
                    if(capacity){
                        this.InfoList[i].capacity = capacity;
                    }
                    if(robot_id){
                        this.InfoList[i].robot_id = robot_id;
                    }
                    if(status){
                        this.InfoList[i].status = status;
                        console.log(this.InfoList);
                    }
                }
            }
        },
        check_rest(){
            this.InfoList = []
            for (let i = 0; i < this.restList.length; i++) {
                if(this.restList[i].rest_id==this.rest_id){
                    this.isExist = true;
                    this.show_move_area = true;
                    this.rest_x = this.restList[i].rest_x
                    this.rest_y = this.restList[i].rest_y
                    this.height = Number(this.restList[i].rest_y)
                    axios.post('/getTable',{
                            rest_id:this.rest_id
                        }).then((response)=>{
                            for (let j = 0; j < response.data['tables'].length; j++) {
                                var table_y = (Number(response.data['tables'][j].table_y)-70).toString()
                                this.InfoList.push({
                                    x:response.data['tables'][j].table_x,
                                    y:table_y,
                                    capacity:response.data['tables'][j].capacity,
                                    robot_id:response.data['tables'][j].robot_id,
                                    id:response.data['tables'][j].table_no,
                                    status:response.data['tables'][j].status
                                });
                                this.counter++;
                            }
                    });
                }
            }
        },
        methodToRunOnSelect(payload) {
            this.selectedObj = payload;
            this.rest_id = this.selectedObj.name
            this.check_rest();
        },
        refresh(){
            this.InfoList= [],
            this.restList= [],
            this.rest_id="",
            this.rest_x="",
            this.rest_y="",
            this.height=0,
            this.show_move_area= false,
            this.isVisible=false,
            this.editingTableId="",
            this.isExist=false
        }

    },
}
</script>

<style>
    .drag{
        position: absolute;
    }

    .move-area{
        border-color: black;
        border-style: solid;
        border-width: medium;
    }
    .img1{
        width: 50px;
    }
    .table_icon{
        width: 50px;
    }
    :root {
        --popper-theme-background-color: #333333;
        --popper-theme-background-color-hover: #333333;
        --popper-theme-text-color: #ffffff;
        --popper-theme-border-width: 0px;
        --popper-theme-border-style: solid;
        --popper-theme-border-radius: 6px;
        --popper-theme-padding: 32px;
        --popper-theme-box-shadow: 0 6px 30px -6px rgba(0, 0, 0, 0.25);
        white-space: pre-line;
    }
    .inline-block{
        position: absolute;
    }
    .popper{
        position: relative !important;
        transform: translate(-80px, 0px) !important;
    }
</style>
