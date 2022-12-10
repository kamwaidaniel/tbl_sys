<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Inertia\Inertia;
use App\Models\Suggest;
use App\Models\Table;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class SuggestController extends Controller
{
    /**
     * Show the form for creating a new resource.
     *
     * @return Response
     */
    public function index()
    {
        $suggests = Suggest::all();
        return Inertia::render('Suggests/Index', ['suggest' => $suggests]);
    }

    /**
     * Write code on Method
     *
     * @return response()
     */
    public function create()
    {
        return Inertia::render('Suggests/Create');
    }
    
    /**
     * Show the form for creating a new resource.
     *
     * @return Response
     */
    public function store(Request $request)
    {
        Validator::make($request->all(), [
            'title' => ['required'],
            'body' => ['required'],
        ])->validate();
   
        Suggest::create($request->all());
    
        return redirect()->route('suggests.index');
    }
  
    /**
     * Write code on Method
     *
     * @return response()
     */
    public function edit(Suggest $suggest)
    {
        return Inertia::render('Suggests/Edit', [
            'suggest' => $suggest
        ]);
    }
    
    /**
     * Show the form for creating a new resource.
     *
     * @return Response
     */
    public function update($id, Request $request)
    {
        Validator::make($request->all(), [
            'title' => ['required'],
            'body' => ['required'],
        ])->validate();
    
        Suggest::find($id)->update($request->all());
        return redirect()->route('suggests.index');
    }
    
    /**
     * Show the form for creating a new resource.
     *
     * @return Response
     */
    public function destroy($id)
    {
        Post::find($id)->delete();
        return redirect()->route('suggests.index');
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return Response
     */
    public function getSuggest()
    {
        $suggests = Suggest::whereRaw("status = 'PENDING' or status = 'WAITING' ")->get();
        return response()->json([
            'suggests' => $suggests
        ]);
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return Response
     */
    public function getTableById(Request $request)
    {
        $tables = Table::whereRaw('table_id = ? ', $request->table_id)->get();
        return response()->json([
            'tables' => $tables
        ]);
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return Response
     */
    public function updateStatus(Request $request)
    {
        Suggest::whereRaw('suggest_id = ? ', $request->suggest_id)->update($request->all());
        return response()->json([
            'message' => "The suggest has been "
        ]);
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return Response
     */
    public function getSuggestByTableId(Request $request)
    {
        $suggest = Suggest::whereRaw("status = 'WAITING' and table_id = ?",$request->table_id)->get();
        return response()->json([
            'suggest' => $suggest
        ]);
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return Response
     */
    public function productSuggest(Request $request)
    {
        DB::select('call sp_getSuggestTable(?,?)',array($request->no_of_ppl,$request->rest_id));
        return response()->json([
            'message' => "generated"
        ]);
    }
}