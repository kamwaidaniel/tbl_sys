import{u as f,o as r,g as d,a as o,b as t,w as i,F as p,H as b,d as e,L as h,e as x,f as y,t as m,k as n}from"./app.df7a48ba.js";import{_ as g}from"./AuthenticatedLayout.e202d503.js";import{_ as c,a as v}from"./TextInput.354c703c.js";import{_ as w}from"./Textarea.21722af8.js";import"./ApplicationLogo.13c20baa.js";import"./_plugin-vue_export-helper.cdc0426e.js";import"./mqtt.min.77c8ccfe.js";const N=e("h2",{class:"font-semibold text-xl text-gray-800 leading-tight"}," Create Post ",-1),V={class:"py-12"},k={class:"max-w-7xl mx-auto sm:px-6 lg:px-8"},B={class:"bg-white overflow-hidden shadow-sm sm:rounded-lg"},C={class:"p-6 bg-white border-b border-gray-200"},F={className:"flex items-center justify-between mb-6"},S=["onSubmit"],$={className:"flex flex-col"},D={className:"mb-4"},H={key:0,className:"text-red-600"},L={className:"mb-4"},T={key:0,className:"text-red-600"},U=e("div",{className:"mt-4"},[e("button",{type:"submit",className:"px-6 py-2 font-bold text-white bg-green-500 rounded"}," Save ")],-1),I={__name:"Create",setup(j){const s=f({title:"",body:""}),u=()=>{s.post(route("posts.store"))};return(_,a)=>(r(),d(p,null,[o(t(b),{title:"Dashboard"}),o(g,null,{header:i(()=>[N]),default:i(()=>[e("div",V,[e("div",k,[e("div",B,[e("div",C,[e("div",F,[o(t(h),{className:"px-6 py-2 text-white bg-blue-500 rounded-md focus:outline-none",href:_.route("posts.index")},{default:i(()=>[x(" Back ")]),_:1},8,["href"])]),e("form",{name:"createForm",onSubmit:y(u,["prevent"])},[e("div",$,[e("div",D,[o(c,{for:"title",value:"Title"}),o(v,{id:"title",type:"text",class:"mt-1 block w-full",modelValue:t(s).title,"onUpdate:modelValue":a[0]||(a[0]=l=>t(s).title=l),autofocus:""},null,8,["modelValue"]),t(s).errors.title?(r(),d("span",H,m(t(s).errors.title),1)):n("",!0)]),e("div",L,[o(c,{for:"body",value:"Body"}),o(w,{id:"body",class:"mt-1 block w-full",modelValue:t(s).body,"onUpdate:modelValue":a[1]||(a[1]=l=>t(s).body=l),autofocus:""},null,8,["modelValue"]),t(s).errors.body?(r(),d("span",T,m(t(s).errors.body),1)):n("",!0)])]),U],40,S)])])])])]),_:1})],64))}};export{I as default};