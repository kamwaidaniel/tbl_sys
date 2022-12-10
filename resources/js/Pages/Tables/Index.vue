<template>
    <Head title="Dashboard" />
    <BreezeAuthenticatedLayout>
        <template #header>
            <h2 class="font-semibold text-xl text-gray-800 leading-tight">
                Please Edit the tables in the Restaurant
            </h2>
        </template>
        <vue-basic-alert :duration="1500" :closeIn="5000" ref="alert" />
        <div class="py-12">
            <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
                <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg">
                    <div class="p-6 bg-white border-b border-gray-200">
                        <div className="flex items-center justify-between mb-6">
                            1. Please input the restaurant name
                        </div>
                        <div className="flex items-center justify-between mb-6">
                            <BreezeInput 
                                id="rest_id" 
                                type="text" 
                                class="mt-1 block w-50" 
                                v-model="rest_id" 
                                @change="check_rest"
                                autofocus />
                        </div>
                        <div className="flex items-center justify-between mb-6">
                            2. Please input the restaurant length and width
                        </div>
                        <div className="flex items-center mb-6">
                            <BreezeLabel value="width(ft)" /> 
                            <BreezeInput 
                                id="rest_x" 
                                type="text" 
                                class="mt-1 block w-40" 
                                v-model="rest_x" 
                                @keyup="input_area"
                                autofocus />
                        </div>
                        <div className="flex items-center mb-6">
                            <BreezeLabel value="height(ft)" /> 
                            <BreezeInput 
                                id="rest_y" 
                                type="text" 
                                class="mt-1 block w-40" 
                                @keyup="input_area"
                                v-model="rest_y" 
                                autofocus />
                        </div>
                        <div className="flex items-center justify-between mb-6">
                            3. Please drag and drop the table
                        </div>
                        <div >
                            <div class="drag">
                                <el-container>
                                    <el-aside width="300px">
                                    <ul>
                                        <img
                                            class="table_icon"
                                            src="@/img/green_table.png"
                                            @dragstart="dragStart"
                                            draggable="true"
                                            :id="item"
                                            @dragend="dragEnd"
                                            @drag="ondrag"
                                        />
                                    </ul>
                                    </el-aside>
                                </el-container>
                                <div>
                                    <el-main>
                                        <div id="movearea" v-if="show_move_area" :style="{width:rest_x+'px',height:rest_y+'px'}" @drop.prevent="drop" @dragover.prevent ref="moveArea" class="move-area">
                                            <div v-for="(info, index) in InfoList" :key="index">
                                                <div v-if="info.tblImg">
                                                    <img
                                                        src="@/img/green_table.png"
                                                        class="msg1"
                                                        :id="info.id"
                                                        :style="{left:info.x+'px',top:info.y+'px'}"
                                                        :key="index"
                                                        draggable="true"
                                                        @dragstart="imgStart"
                                                        @drag="imgDragging($event, info)"
                                                        v-on:dblclick="showPopUp(info.id)"
                                                        @dragend="dragEnd"
                                                    />
                                                </div>
                                                <div v-else>
                                                    <img
                                                        src="@/img/green_table2.png"
                                                        class="msg1"
                                                        :id="info.id"
                                                        :style="{left:info.x+'px',top:info.y+'px'}"
                                                        :key="index"
                                                        draggable="true"
                                                        @dragstart="imgStart"
                                                        @drag="imgDragging($event, info)"
                                                        v-on:dblclick="showPopUp(info.id)"
                                                        @dragend="dragEnd"
                                                    />
                                                </div>
                                            </div>
                                        </div>
                                    </el-main>
                                </div>
                            </div>
                        </div>
                        <div className="flex items-center justify-between mb-6" :style="{'margin-top':(buttonTop+height)+'px'}">
                            <div v-if="isExist">
                                <button
                                    @click="update()"
                                    tabIndex="-1"
                                    type="submit"
                                    className="px-6 py-2 font-bold text-white bg-green-500 rounded">
                                Update
                                </button>
                                <button
                                    @click="del()"
                                    tabIndex="-1"
                                    type="button"
                                    className="mx-1 px-4 py-2 text-sm text-white bg-red-500 rounded"
                                >
                                    Delete
                                </button>
                            </div>
                            <div v-else>
                                <button
                                    @click="submit()"
                                    tabIndex="-1"
                                    type="submit"
                                    className="px-6 py-2 font-bold text-white bg-green-500 rounded">
                                Submit
                                </button>
                            </div>
                        </div>
                        <Modal v-model:visible="isVisible" :title="this.editingTableId+' infomation'" :okButton="{onclick: () => {this.inputTableInfo();}}">
                            <BreezeLabel value="Capacity" />
                            <BreezeInput 
                                id="capacity" 
                                type="text" 
                                class="mt-1 block w-40" 
                                v-model="capacity" 
                                autofocus />
                            <BreezeLabel value="Robot" />
                            <BreezeInput 
                                id="robot_id" 
                                type="text" 
                                class="mt-1 block w-40" 
                                v-model="robot_id"
                                autofocus />
                        </Modal>
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
import VueBasicAlert from 'vue-basic-alert'

export default {
    components: {
        BreezeAuthenticatedLayout,
        BreezeLabel,
        BreezeInput,
        Modal,
        VueBasicAlert
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
            buttonTop:150,
            editingTableId:"",
            msg:"",
            isExist:false
        }
    },
    created () {
        window.addEventListener('scroll', this.handleScroll);
        axios.get('/getRest').then((response)=>{
                console.log(response);
                this.restList = response.data['rests'];
        });
    },
    destroyed () {
        window.removeEventListener('scroll', this.handleScroll);
    },
    mounted () {
        this.GetElementDistance();
    },
    methods: {
        dragStart(ev) {
            //start to drag the table on the area
            let info = { id: ev.target.id, isDrop: true }
            ev.dataTransfer.setData('Text', JSON.stringify(info))
            this.offsetX = ev.offsetX
            this.offsetY = ev.offsetY
        },

        dragEnd(event) {
            console.log('done')
            event.dataTransfer.clearData()
        },

        //handling add new table on the area
        drop(e) {
            let info = JSON.parse(e.dataTransfer.getData('Text'))
            if (info.isDrop) {
                info.x = e.clientX - this.offsetX - this.offLeft
                info.y = e.clientY - this.offsetY - this.offTop
                info.tblImg = true
                //provide the id to the table
                info.id = "table" + this.counter;
                this.InfoList.push(info);
                this.counter++;
            }
        },

        imgStart(e) {
            //image in the area that no need to drop
            let info = { isDrop: false }
            e.dataTransfer.setData('Text', JSON.stringify(info))
            this.imgOffsetX = e.offsetX
            this.imgOffsetY = e.offsetY
        },

        imgDragging(e, item) {
            if(this.canOut){
                item.x = e.clientX - this.imgOffsetX - this.offLeft
                item.y = e.clientY - this.imgOffsetY - this.offTop
            }else{
                const area = this.$refs.moveArea
                const x=e.clientX;
                const y=e.clientY;
                const areax1 = area.offsetLeft + this.offLeft;
                const areay1 = area.offsetTop + this.offTop;
                const areax2 = areax1 + area.offsetWidth;
                const areay2 = areay1 + area.offsetHeight;
                //when image is moving on the area
                if( x >= areax1 && x <= areax2 && y >= areay1 && y <= areay2){
                    item.x = e.clientX - this.imgOffsetX - this.offLeft
                    item.y = e.clientY - this.imgOffsetY - this.offTop
                }
            }
        },

        ondrag(e) {
            console.log("")
        },

        input_area() {
            if(this.rest_x && this.rest_y){
                this.show_move_area = true;
                this.height = Number(this.rest_y)
            } else {
                this.show_move_area = false;
            }
        },
        GetElementDistance() {
            var div = document.getElementById("movearea");
            if(div){
                this.offTop = div.getBoundingClientRect().top-50;
                this.offLeft = div.getBoundingClientRect().left-20;
            }
        },
        inputTableInfo(){
            this.assignValueToInfoList(this.editingTableId,"","",this.capacity,this.robot_id);
            console.log("done");
            this.isVisible = false;
            
        },
        showPopUp(table_no){
            this.isVisible = true;
            this.editingTableId = table_no;
            this.capacity = 0;
            this.robot_id = "";
        },
        handleScroll() {
            this.GetElementDistance();
        },
        assignValueToInfoList(table_id,x,y,capacity,robot_id){
            for (let i = 0; i < this.InfoList.length; i++) {
                if(this.InfoList[i].id==table_id){
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
                    if(this.InfoList[i].capacity && this.InfoList[i].robot_id){
                        this.InfoList[i].tblImg = false;
                    }
                }
            }
        },
        submit(){
            this.msg = this.validate();
            if(!this.msg){
                axios.post('/createRest',{
                        rest_id:this.rest_id,
                        rest_x:this.rest_x,
                        rest_y:this.rest_y
                    }
                    ).then((response)=>{
                        this.$refs.alert
                        .showAlert(
                            'success', // There are 4 types of alert: success, info, warning, error
                            response.data['message'],
                            'success!', 
                            'Success 200'
                        )
                });
                for (let i = 0; i < this.InfoList.length; i++) {
                    axios.post('/createTable',{
                            table_no:this.InfoList[i].id,
                            rest_id:this.rest_id,
                            capacity:this.InfoList[i].capacity,
                            table_x:this.InfoList[i].x,
                            table_y:this.InfoList[i].y,
                            status:"ACTIVE",
                            robot_id:this.InfoList[i].robot_id,
                        }
                        ).then((response)=>{
                            console.log(response);
                    });
                }
            } else{
                this.$refs.alert
                .showAlert(
                    'error', // There are 4 types of alert: success, info, warning, error
                    this.msg,
                    'Error!', 
                    'Error 200'
                )
            }
        },
        validate(){
            if(!this.rest_id){
                return "Missing restaurant name.";
            }
            if(!this.rest_x ||!this.rest_y){
                return "Missing width or height.";
            }
            for (let i = 0; i < this.InfoList.length; i++) {
                if(!this.InfoList[i].capacity || !this.InfoList[i].robot_id){
                    return "Please double click robot and input Capacity or robot name for "+this.InfoList[i].id;
                }
            }
            return "";
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
                                this.InfoList.push({
                                    x:response.data['tables'][j].table_x,
                                    y:response.data['tables'][j].table_y,
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
        update(){
            this.msg = this.validate();
            if(!this.msg){
                axios.post('/updateRest',{
                        rest_id:this.rest_id,
                        rest_x:this.rest_x,
                        rest_y:this.rest_y
                    }
                    ).then((response)=>{
                        console.log(response.data['message']);
                        this.$refs.alert
                        .showAlert(
                            'success', // There are 4 types of alert: success, info, warning, error
                            response.data['message'],
                            'success!', 
                            'Success 200'
                        )
                });
                for (let i = 0; i < this.InfoList.length; i++) {
                    console.log(this.InfoList[i])
                    axios.post('/delTable',{
                            rest_id:this.rest_id,
                            table_no:this.InfoList[i].id
                        }).then((response)=>{
                            console.log('test this.InfoList.id');
                            console.log(this.InfoList[i].id);
                            if(!this.InfoList[i].status){
                                this.InfoList[i].status = "ACTIVE"
                            }
                            axios.post('/createTable',{
                                table_no:this.InfoList[i].id,
                                rest_id:this.rest_id,
                                capacity:this.InfoList[i].capacity,
                                table_x:this.InfoList[i].x,
                                table_y:this.InfoList[i].y,
                                status:this.InfoList[i].status,
                                robot_id:this.InfoList[i].robot_id,
                            }
                            ).then((response)=>{
                                console.log(response);
                        });
                    });
                }
            } else{
                this.$refs.alert
                .showAlert(
                    'error', // There are 4 types of alert: success, info, warning, error
                    this.msg,
                    'Error!', 
                    'Error 200'
                )
            }
        },
        del(){
            axios.post('/delRest',{rest_id:this.rest_id}
                ).then((response)=>{
                    this.$refs.alert
                        .showAlert(
                            'success', // There are 4 types of alert: success, info, warning, error
                            response.data['message'],
                            'success!', 
                            'Success 200'
                        )
            });
            for (let i = 0; i < this.InfoList.length; i++) {
                console.log(this.InfoList[i])
                axios.post('/delTable',{
                        rest_id:this.rest_id,
                        table_no:this.InfoList[i].id
                    }).then((response)=>{
                        this.refresh();
                });
            }
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
    .el-container{
        height:50px;
    }

    .el-main {
        background: #cff9dc3b;
    }
    .move-area{
        border-color: black;
        border-style: solid;
        border-width: medium;
    }
    .msg1{
        position: absolute;
        width: 50px;
    }
    .table_icon{
        width: 50px;
    }
</style>
