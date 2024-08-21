// cell_width = 188.4 pixels
// line_width = 5.05 pixels

// 4mm x 4mm x 4mm
cell_width = 4;

line_width = 0.13;
// possible edging types
// 0 no edging
// 1 topleft, topright+
// 2 botleft, botright+
// 3 topright, topleft+
// 4 botright, botleft+
//
// 5 botleft, botright-
// 6 topleft, topright-
// 7 botright, botleft-
// 8 topright, topleft-
//
// line_inclusion is an array of four line_inclusion types (which can be 0 for no inclusion, 1 for inclusion, 2 for cut)
// in the order of top, right, bot, left
//
// spawn orientation
// 0 for none, 1 for top, 2 for right, 3 for bot, 4 for left
module terrain_cube(height_mod, edging_type, line_inclusion, face_shrink, spawn_orientation)
{

    shrink = 0.1;

    shrink_x_change_0 = face_shrink[1] ? -shrink : 0;
    shrink_x_change_1 = face_shrink[3] ? -shrink : 0;

    line_x_change_0 = line_inclusion[1] != 2 ? line_width : 0;
    line_x_change_1 = line_inclusion[3] != 2 ? line_width : 0;

    x = cell_width + shrink_x_change_0 + shrink_x_change_1 + line_x_change_0 + line_x_change_1;

    shrink_y_change_0 = face_shrink[0] ? -shrink : 0;
    shrink_y_change_1 = face_shrink[2] ? -shrink : 0;

    line_y_change_0 = line_inclusion[0] != 2 ? line_width : 0;
    line_y_change_1 = line_inclusion[2] != 2 ? line_width : 0;

    y = cell_width + shrink_y_change_0 + shrink_y_change_1 + line_y_change_0 + line_y_change_1;

    module spawn_marker()
    {
        unit = cell_width / 5;
        translate([ -0.5 * unit, -1 / 3 * unit ]) polygon([
            [ 0, 0 ], [ unit, 0 ], [ unit, unit / 3 ], [ 2 / 3 * unit, unit / 3 ], [ 2 / 3 * unit, unit * 2 / 3 ],
            [ 1 / 3 * unit, unit * 2 / 3 ], [ 1 / 3 * unit, 1 / 3 * unit ], [ 0, 1 / 3 * unit ]
        ]);
    }

    module edge_triangle(edging_type)
    {
        height = 0.58;

        neg_height = 0.7;
        offset(0.01)
        {
            if (edging_type == 1)
            {
                translate([ 0, y ]) polygon([ [ 0, 0 ], [ x, 0 ], [ x, height ] ]);
            }
            else if (edging_type == 2)
            {
                polygon([
                    [ x, -height ],
                    [ x, 0 ],
                    [ 0, 0 ],
                ]);
            }
            else if (edging_type == 3)
            {
#polygon([ [ 0, y + height ], [ x, y ], [ 0, y ] ]);
            }
            else if (edging_type == 4)
            {
                polygon([ [ 0, 0 ], [ x, 0 ], [ 0, -height ] ]);
            }
            else if (edging_type == 5)
            {
                polygon([ [ 0, 0 ], [ x, neg_height ], [ x, 0 ] ]);
            }
            else if (edging_type == 6)
            {
                polygon([ [ 0, y ], [ x, y ], [ x, y - neg_height ] ]);
            }
            else if (edging_type == 7)
            {
                polygon([ [ 0, 0 ], [ 0, neg_height ], [ x, 0 ] ]);
            }
            else if (edging_type == 8)
            {
                polygon([ [ 0, y ], [ x, y ], [ 0, y - neg_height ] ]);
            }
        }
    }

    module enlarged_square()
    {
        offset(0.01) square([ x, y ]);
    }
    difference()
    {
        height = (height_mod + 1) * cell_width;
        linear_extrude(height)
        {

            if (edging_type != 0)
            {
                if (edging_type < 5)
                {
                    union()
                    {
                        enlarged_square();
                        edge_triangle(edging_type);
                    }
                }
                else
                {
                    difference()
                    {
                        enlarged_square();
                        edge_triangle(edging_type);
                    }
                }
            }
            else
            {
                enlarged_square();
            }
        }
        if (spawn_orientation != 0)
        {
            marker_depth = 0.2;
            translate([ x / 2, y / 2, height - marker_depth + 0.01 ])
            {
                rotate([ 0, 0, -90 * (spawn_orientation - 1) ])
                {
                    color("black") linear_extrude(marker_depth) spawn_marker();
                }
            }
        }

        line_depth = 0.2;
        translate([ 0, 0, -line_depth + height + 0.01 ]) color("white") linear_extrude(line_depth) union()
        {

            if (line_inclusion[0] == 1)
            {
                translate([ -0.02, y - line_width ]) square([ x + 0.04, line_width ]);
            }
            if (line_inclusion[1] == 1)
            {
                translate([ x - line_width, -0.02 ]) square([ line_width, y + 0.04 ]);
            }
            if (line_inclusion[2] == 1)
            {
                translate([ -0.02, 0 ]) square([ x + line_width, line_width + 0.04 ]);
            }
            if (line_inclusion[3] == 1)
            {
                translate([ 0, -0.02 ]) square([ line_width + 0.04, y ]);
            }
        }
    }
}

module right_spawn()
{
    translate([ 0, 2 * cell_width + 2 * line_width, 0 ]) terrain_cube(0, 3, [ 1, 2, 1, 2 ], no_shrink, 4);
    translate([ 0, cell_width + line_width, 0 ]) terrain_cube(0, 0, [ 2, 2, 1, 2 ], no_shrink, 4);
    terrain_cube(0, 4, [ 2, 2, 1, 2 ], no_shrink, 4);
}

module side_spawn()
{
    // flow_bar_width = 2.17;
    // flow_bar_height = 13.77;

    shrink_right = [ false, true, false, false ];
    translate([ 0, 2 * cell_width + line_width, 0 ]) terrain_cube(1, 1, [ 1, 2, 0, 2 ], no_shrink, 2);
    translate([ 0, cell_width + line_width, 0 ]) terrain_cube(2, 0, [ 2, 2, 0, 2 ], no_shrink, 2);
    terrain_cube(1, 2, [ 2, 2, 1, 2 ], no_shrink, 2);
}

bulge_offset = -0.4 * cell_width * 0.5;

cavity_depth = 0.2 * cell_width;

module installable()
{
    difference()
    {
        children();

        translate([ 0, 0, -0.01 ]) linear_extrude(cavity_depth) offset(r = bulge_offset) projection(cut = false)
            children();
    }
}

module heightener()
{

    difference()
    {
        union()
        {
            linear_extrude(cell_width) projection(cut = false) children();
            ;

            translate([ 0, 0, cell_width ]) linear_extrude(cavity_depth - 0.1) offset(r = bulge_offset - 0.1)
                projection(cut = false) children();
        }

        translate([ 0, 0, -0.01 ]) linear_extrude(cavity_depth) offset(r = bulge_offset) projection(cut = false)
            children();
    }
}

no_shrink = [ false, false, false, false ];

include_right_and_bot = [ 2, 1, 1, 2 ];

module starting_two_rows()
{

    terrain_cube(0, 0, [ 2, 1, 2, 2 ], no_shrink, 0);
    translate([ cell_width + line_width, 0, 0 ]) terrain_cube(0, 0, [ 2, 1, 2, 2 ], no_shrink, 0);

    translate([ 2 * (cell_width + line_width), 0, 0 ]) terrain_cube(0, 0, [ 2, 1, 2, 2 ], no_shrink, 1);
    translate([ 3 * (cell_width + line_width), 0, 0 ]) terrain_cube(0, 0, [ 2, 1, 2, 2 ], no_shrink, 1);
    translate([ 4 * (cell_width + line_width), 0, 0 ]) terrain_cube(0, 0, [ 2, 1, 2, 2 ], no_shrink, 1);
    translate([ 5 * (cell_width + line_width), 0, 0 ]) terrain_cube(0, 0, [ 2, 1, 2, 2 ], no_shrink, 0);
    translate([ 6 * (cell_width + line_width), 0, 0 ]) terrain_cube(0, 0, [ 2, 2, 2, 2 ], no_shrink, 0);

    translate([ 0, 1 * cell_width ]) terrain_cube(0, 0, [ 2, 1, 1, 2 ], no_shrink, 0);
    translate([ cell_width + line_width, 1 * cell_width, 0 ]) terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 2 * (cell_width + line_width), 1 * cell_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 3 * (cell_width + line_width), 1 * cell_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 4 * (cell_width + line_width), 1 * cell_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 5 * (cell_width + line_width), 1 * cell_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 6 * (cell_width + line_width), 1 * cell_width, 0 ]) terrain_cube(0, 0, [ 2, 2, 1, 2 ], no_shrink, 0);
}

module last_third_left()
{

    translate([ 0, 8 * cell_width + 7 * line_width, 0 ]) terrain_cube(0, 0, [ 2, 1, 1, 2 ], no_shrink, 0);
    translate([ cell_width + line_width, 8 * cell_width + 7 * line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 2 * (cell_width + line_width), 8 * cell_width + 7 * line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 3 * (cell_width + line_width), 8 * cell_width + 7 * line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 4 * (cell_width + line_width), 8 * cell_width + 7 * line_width, 0 ])
        terrain_cube(0, 0, [ 2, 1, 1, 2 ], no_shrink, 0);
}

module top_two_rows()
{

    translate([ 0, cell_width + line_width ]) last_third_left();
    translate([ 5 * (cell_width + line_width), 9 * cell_width + 8 * line_width, 0 ])
        terrain_cube(0, 0, [ 2, 1, 1, 2 ], no_shrink, 0);
    translate([ 6 * (cell_width + line_width), 9 * cell_width + 8 * line_width, 0 ])
        terrain_cube(0, 0, [ 2, 2, 1, 2 ], no_shrink, 0);

    translate([ 0, 10 * cell_width + 9 * line_width, 0 ]) terrain_cube(0, 0, [ 2, 1, 1, 2 ], no_shrink, 0);
    translate([ cell_width + line_width, 10 * cell_width + 9 * line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 2 * (cell_width + line_width), 10 * cell_width + 9 * line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 3);
    translate([ 3 * (cell_width + line_width), 10 * cell_width + 9 * line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 3);
    translate([ 4 * (cell_width + line_width), 10 * cell_width + 9 * line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 3);
    translate([ 5 * (cell_width + line_width), 10 * cell_width + 9 * line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 6 * (cell_width + line_width), 10 * cell_width + 9 * line_width, 0 ])
        terrain_cube(0, 0, [ 2, 2, 1, 2 ], no_shrink, 0);
}

module fifth_row()
{

    translate([ cell_width + line_width, 4 * cell_width + 3 * line_width, 0 ])
        terrain_cube(0, 0, [ 2, 1, 1, 2 ], no_shrink, 0);
    translate([ 2 * (cell_width + line_width), 4 * cell_width + 3 * line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 3 * (cell_width + line_width), 4 * cell_width + 3 * line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 4 * (cell_width + line_width), 4 * cell_width + 3 * line_width, 0 ])
        terrain_cube(0, 0, [ 2, 0, 1, 2 ], no_shrink, 0);
    translate([ 5 * (cell_width + line_width), 4 * cell_width + 3 * line_width, 0 ])
        terrain_cube(2, 0, [ 2, 2, 1, 2 ], no_shrink, 0);
}
module piece_left()
{

    starting_two_rows();

    translate([ 0, 2 * cell_width + 1 * line_width ]) terrain_cube(0, 0, [ 2, 1, 1, 2 ], no_shrink, 0);
    translate([ cell_width + line_width, 2 * cell_width + 1 * line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 2 * (cell_width + line_width), 2 * cell_width + 1 * line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 3 * (cell_width + line_width), 2 * cell_width + line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 4 * (cell_width + line_width), 2 * cell_width + line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 5 * (cell_width + line_width), 2 * cell_width + line_width, 0 ])
        terrain_cube(0, 0, [ 0, 1, 1, 2 ], no_shrink, 0);
    translate([ 6 * (cell_width + line_width), 2 * cell_width + line_width, 0 ])
        terrain_cube(0, 0, [ 0, 2, 1, 2 ], no_shrink, 0);

    translate([ 0, 3 * cell_width + 2 * line_width ]) terrain_cube(0, 6, [ 2, 1, 1, 2 ], no_shrink, 0);
    translate([ cell_width + line_width, 3 * cell_width + 2 * line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 2 * (cell_width + line_width), 3 * cell_width + 2 * line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 3 * (cell_width + line_width), 3 * cell_width + 2 * line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 4 * (cell_width + line_width), 3 * cell_width + 2 * line_width, 0 ])
        terrain_cube(0, 0, [ 2, 0, 1, 0 ], no_shrink, 0);
    translate([ 5 * (cell_width + line_width), 3 * cell_width + 2 * line_width, 0 ])
        terrain_cube(2, 0, [ 2, 2, 0, 2 ], no_shrink, 0);
    translate([ 6 * (cell_width) + 5 * line_width, 3 * cell_width + 2 * line_width, 0 ])
        terrain_cube(2, 6, [ 2, 2, 0, 1 ], no_shrink, 0);

    fifth_row();
    translate([ 0, cell_width + line_width ]) fifth_row();
    translate([ 0, 2 * (cell_width + line_width) ]) fifth_row();

    translate([ 0, 7 * cell_width + 7 * line_width, 0 ]) terrain_cube(0, 5, [ 2, 1, 2, 2 ], no_shrink, 0);
    translate([ cell_width + line_width, 7 * cell_width + 6 * line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 2 * (cell_width + line_width), 7 * cell_width + 6 * line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 3 * (cell_width + line_width), 7 * cell_width + 6 * line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 4 * (cell_width + line_width), 7 * cell_width + 6 * line_width, 0 ])
        terrain_cube(0, 0, [ 2, 0, 1, 2 ], no_shrink, 0);
    translate([ 5 * (cell_width + line_width), 7 * cell_width + 6 * line_width, 0 ])
        terrain_cube(2, 0, [ 2, 2, 1, 2 ], no_shrink, 0);
    translate([ 6 * (cell_width) + 5 * line_width, 7 * cell_width + 7 * line_width, 0 ])
        terrain_cube(2, 7, [ 2, 2, 2, 1 ], no_shrink, 0);

    last_third_left();
    translate([ 5 * (cell_width + line_width), 8 * cell_width + 7 * line_width, 0 ])
        terrain_cube(0, 0, [ 2, 1, 0, 2 ], no_shrink, 0);
    translate([ 6 * (cell_width + line_width), 8 * cell_width + 7 * line_width, 0 ])
        terrain_cube(0, 0, [ 2, 2, 0, 2 ], no_shrink, 0);

    top_two_rows();
}

module middle_piece()
{
    terrain_cube(0, 4, [ 2, 0, 1, 2 ], no_shrink, 0);
    translate([ cell_width + line_width, 0, 0 ]) terrain_cube(1, 2, [ 2, 2, 1, 2 ], no_shrink, 0);

    translate([ 0, cell_width + line_width ]) terrain_cube(0, 0, [ 2, 0, 1, 2 ], no_shrink, 0);
    translate([ cell_width + line_width, cell_width + line_width, 0 ]) terrain_cube(1, 0, [ 2, 2, 1, 2 ], no_shrink, 0);

    translate([ 0, 2 * (cell_width + line_width) ]) terrain_cube(0, 3, [ 1, 0, 1, 2 ], no_shrink, 0);

    translate([ cell_width + line_width, 2 * (cell_width + line_width), 0 ])
        terrain_cube(1, 1, [ 1, 2, 1, 2 ], no_shrink, 0);
}

module right_piece()
{
    starting_two_rows();

    translate([ 0, 2 * cell_width + 1 * line_width ]) terrain_cube(0, 0, [ 2, 1, 1, 2 ], no_shrink, 0);
    translate([ cell_width + line_width, 2 * cell_width + 1 * line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 2 * (cell_width + line_width), 2 * cell_width + 1 * line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 3 * (cell_width + line_width), 2 * cell_width + line_width, 0 ])
        terrain_cube(0, 0, [ 0, 1, 1, 2 ], no_shrink, 0);
    translate([ 4 * (cell_width + line_width), 2 * cell_width + line_width, 0 ])
        terrain_cube(0, 0, [ 0, 1, 1, 2 ], no_shrink, 0);
    translate([ 5 * (cell_width + line_width), 2 * cell_width + line_width, 0 ])
        terrain_cube(0, 0, [ 0, 1, 1, 2 ], no_shrink, 0);
    translate([ 6 * (cell_width + line_width), 2 * cell_width + line_width, 0 ])
        terrain_cube(0, 0, [ 0, 2, 1, 2 ], no_shrink, 0);

    translate([ 0, 3 * cell_width + 2 * line_width ]) terrain_cube(0, 6, [ 2, 1, 1, 2 ], no_shrink, 0);
    translate([ cell_width + line_width, 3 * cell_width + 2 * line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 2 * (cell_width + line_width), 3 * cell_width + 2 * line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 3 * (cell_width + line_width), 3 * (cell_width + line_width), 0 ])
        terrain_cube(1, 0, [ 2, 1, 2, 2 ], no_shrink, 0);
    translate([ 4 * (cell_width + line_width), 3 * (cell_width + line_width), 0 ])
        terrain_cube(1, 0, [ 2, 0, 2, 2 ], no_shrink, 0);
    translate([ 5 * (cell_width + line_width), 3 * cell_width + 3 * line_width, 0 ])
        terrain_cube(2, 0, [ 2, 2, 2, 2 ], no_shrink, 0);
    translate([ 6 * (cell_width) + 5 * line_width, 3 * cell_width + 3 * line_width, 0 ])
        terrain_cube(2, 1, [ 2, 2, 2, 1 ], no_shrink, 0);

    fifth_row();
    translate([ 0, cell_width + line_width ]) fifth_row();

    translate([ cell_width + line_width, 6 * cell_width + 5 * line_width, 0 ])
        terrain_cube(1, 0, [ 2, 1, 0, 2 ], no_shrink, 0);
    translate([ 2 * (cell_width + line_width), 6 * cell_width + 5 * line_width, 0 ])
        terrain_cube(1, 0, [ 2, 0, 0, 2 ], no_shrink, 0);
    translate([ 3 * (cell_width + line_width), 6 * cell_width + 5 * line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 4 * (cell_width + line_width), 6 * cell_width + 5 * line_width, 0 ])
        terrain_cube(0, 0, [ 2, 0, 1, 2 ], no_shrink, 0);
    translate([ 5 * (cell_width + line_width), 6 * cell_width + 5 * line_width, 0 ])
        terrain_cube(2, 0, [ 2, 2, 1, 2 ], no_shrink, 0);

    translate([ 0, 7 * cell_width + 7 * line_width, 0 ]) terrain_cube(0, 5, [ 2, 0, 2, 2 ], no_shrink, 0);
    translate([ cell_width + line_width, 7 * cell_width + 6 * line_width, 0 ])
        terrain_cube(2, 0, [ 2, 0, 0, 2 ], no_shrink, 0);
    translate([ 2 * (cell_width + line_width), 7 * cell_width + 6 * line_width, 0 ])
        terrain_cube(1, 0, [ 2, 0, 1, 2 ], no_shrink, 0);
    translate([ 3 * (cell_width + line_width), 7 * cell_width + 6 * line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 4 * (cell_width + line_width), 7 * cell_width + 6 * line_width, 0 ])
        terrain_cube(0, 0, [ 2, 0, 1, 2 ], no_shrink, 0);
    translate([ 5 * (cell_width + line_width), 7 * cell_width + 6 * line_width, 0 ])
        terrain_cube(2, 0, [ 2, 2, 1, 2 ], no_shrink, 0);
    translate([ 6 * (cell_width) + 5 * line_width, 7 * cell_width + 7 * line_width, 0 ])
        terrain_cube(2, 7, [ 2, 2, 2, 1 ], no_shrink, 0);

    translate([ 0, 8 * cell_width + 7 * line_width ]) terrain_cube(0, 0, [ 2, 1, 1, 2 ], no_shrink, 0);
    translate([ cell_width + line_width, 8 * cell_width + 7 * line_width, 0 ])
        terrain_cube(0, 0, [ 2, 1, 0, 2 ], no_shrink, 0);
    translate([ 2 * (cell_width + line_width), 8 * cell_width + 7 * line_width ])
        terrain_cube(0, 0, [ 2, 1, 0, 2 ], no_shrink, 0);
    translate([ 3 * (cell_width + line_width), 8 * cell_width + 7 * line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 4 * (cell_width + line_width), 8 * cell_width + 7 * line_width, 0 ])
        terrain_cube(0, 0, include_right_and_bot, no_shrink, 0);
    translate([ 5 * (cell_width + line_width), 8 * cell_width + 7 * line_width, 0 ])
        terrain_cube(0, 0, [ 2, 1, 0, 2 ], no_shrink, 0);
    translate([ 6 * (cell_width + line_width), 8 * cell_width + 7 * line_width, 0 ])
        terrain_cube(0, 0, [ 2, 2, 0, 2 ], no_shrink, 0);

    top_two_rows();
}

// installable()
// {
//     // right_spawn();
//     // right_piece();
//     // middle_piece();
//     // piece_left();
//     side_spawn();
// }

// heightener()
// {
//     side_spawn();
// }

module display()
{

    translate([ 7 * cell_width + 7 * line_width, 0 ])
    {
        installable()
        {
            right_piece();
        }
    }

    translate([ 6 * cell_width + 5 * line_width, 4 * cell_width + 3 * line_width ])
    {
        installable()
        {
            middle_piece();
        }
    }

    translate([ 0, 4 * cell_width + 3 * line_width ])
    {
        installable()
        {
            side_spawn();
        }
    }
    installable()
    {
        piece_left();
    }
}

display();
