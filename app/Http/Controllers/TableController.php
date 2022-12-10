<?php
   
namespace App\Http\Controllers;
    
use Illuminate\Http\Request;
use Inertia\Inertia;
use App\Models\Table;
use App\Models\Rest;
use Illuminate\Support\Facades\Validator;
   
class TableController extends Controller
{
    /**
     * Show the form for creating a new resource.
     *
     * @return Response
     */
    public function index()
    {
        $tables = Table::all();
        return Inertia::render('Tables/Index', ['tables' => $tables]);
    }
  
    /**
     * Write code on Method
     *
     * @return response()
     */
    public function create()
    {
        return Inertia::render('Tables/Create');
    }
    
    /**
     * Show the form for creating a new resource.
     *
     * @return Response
     */
    public function store(Request $request)
    {

        Table::create($request->all());
    
        return response()->json([
            'message' => 'created'
        ]);
    }
  
    /**
     * Write code on Method
     *
     * @return response()
     */
    public function edit(Table $table)
    {
        return Inertia::render('Tables/Edit', [
            'table' => $table
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
    
        Table::find($id)->update($request->all());
        return redirect()->route('tables.index');
    }
    
    /**
     * Show the form for creating a new resource.
     *
     * @return Response
     */
    public function destroy($id)
    {
        Table::find($id)->delete();
        return redirect()->route('tables.index');
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return Response
     */
    public function getRest()
    {
        $rests = Rest::all();
        return response()->json([
            'rests' => $rests
        ]);
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return Response
     */
    public function getTable(Request $request)
    {
        $tables = Table::whereRaw('rest_id = ? ', $request->rest_id)->get();
        return response()->json([
            'tables' => $tables
        ]);
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return Response
     */
    public function createTable(Request $request)
    {
        Table::create($request->all());
        return response()->json([
            'message' => 'created'
        ]);
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return Response
     */
    public function createRest(Request $request)
    {
        Rest::create($request->all());
        return response()->json([
            'message' => 'Restaurant has been created'
        ]);
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return Response
     */
    public function updateRest(Request $request)
    {
        Rest::whereRaw('rest_id = ? ', $request->rest_id)->update($request->all());
        return response()->json([
            'message' => 'Restaurant has been updated.'
        ]);
    }


    /**
     * Show the form for creating a new resource.
     *
     * @return Response
     */
    public function delTable(Request $request)
    {
        Table::whereRaw('rest_id = ? ', $request->rest_id)->whereRaw('table_no = ? ', $request->table_no)->delete();
        return response()->json([
            'message' => 'Restaurant has been deleted'
        ]);
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return Response
     */
    public function delRest(Request $request)
    {
        Rest::whereRaw('rest_id = ? ', $request->rest_id)->delete();
        return response()->json([
            'message' => 'Restaurant has been deleted'
        ]);
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return Response
     */
    public function updateStatusById(Request $request)
    {
        Table::whereRaw('table_id = ? ', $request->table_id)->update($request->all());
        return response()->json([
            'message' => 'updated'
        ]);
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return Response
     */
    public function getTableByRestIdTableNo(Request $request)
    {
        $table = Table::whereRaw('rest_id = ? ', $request->rest_id)->whereRaw('table_no = ? ', $request->table_no)->get();
        return response()->json([
            'table' => $table
        ]);
    }
}