import{i as r,j as s,o as n,g as l}from"./app.df7a48ba.js";const i=["value"],c={__name:"Textarea",props:["modelValue"],emits:["update:modelValue"],setup(a){const e=r(null);return s(()=>{e.value.hasAttribute("autofocus")&&e.value.focus()}),(t,o)=>(n(),l("textarea",{class:"border-gray-300 focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50 rounded-md shadow-sm",value:a.modelValue,onInput:o[0]||(o[0]=u=>t.$emit("update:modelValue",u.target.value)),ref_key:"input",ref:e},null,40,i))}};export{c as _};