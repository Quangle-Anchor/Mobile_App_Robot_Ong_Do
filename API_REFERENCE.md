# Robot Ong Do API Reference

Tài liệu này tổng hợp các API FastAPI hiện có trong project để frontend có thể connect và build JSON payload đúng cấu trúc.

## Base URL

- Local: `http://localhost:8000`
- Swagger UI: `http://localhost:8000/docs`
- OpenAPI JSON: `http://localhost:8000/openapi.json`
- ReDoc: `http://localhost:8000/redoc`

## Quy ước chung

- Tất cả request body đều là JSON.
- Pose 6D luôn có dạng `[x, y, z, rx, ry, rz]`.
- `corners` luôn là mảng 4 phần tử, mỗi phần tử là một pose 6D.
- Các endpoint motion có thể trả thêm `result`, `enable_move`, `allow_raw_xmlrpc_motion`, `pose_count`, `stroke_count`, `planned_pose_count`, `motion_mode` tùy luồng xử lý.
- Một số endpoint motion bị khóa bởi config như `enable_robot_move`, `allow_raw_xmlrpc_motion`.

## Health

### GET /health

Kiểm tra service còn sống.

Response:

```json
{
  "status": "ok"
}
```

## Config

### GET /config

Đọc toàn bộ cấu hình hiện tại từ `config/robot_config.json`.

Response là toàn bộ object config, gồm các nhóm chính:

```json
{
  "robot_ip": "192.168.58.2",
  "tool": 0,
  "user": 0,
  "default_vel": 10,
  "enable_robot_move": true,
  "connection_policy": {
    "command_port": 20003,
    "legacy_state_port": 20004,
    "cnde_port": 20005,
    "allow_xmlrpc_motion_when_cnde_unavailable": false,
    "allow_raw_xmlrpc_motion": true
  },
  "robot_workspace": {
    "x_min": -500.0,
    "x_max": 500.0,
    "y_min": -600.0,
    "y_max": 600.0,
    "z_min": 100.0,
    "z_max": 900.0
  },
  "paper": {
    "enabled": true,
    "origin_x": -119.724,
    "origin_y": 569.186,
    "paper_z": 292.206,
    "width_mm": 199.053,
    "height_mm": 263.069,
    "margin_mm": 20.0,
    "coordinate_mode": "measured_corners",
    "draw_orientation": [-179.07, -0.108, -109.105],
    "corners": {
      "top_left": [-119.724, 569.186, 292.854, 177.912, 6.834, -112.557],
      "top_right": [71.557, 563.267, 293.265, 178.668, 5.129, -131.844],
      "bottom_right": [76.606, 294.765, 290.909, -179.276, 0.588, -148.135],
      "bottom_left": [-129.426, 311.78, 291.795, -179.07, -0.108, -109.105]
    }
  },
  "z_safety": {
    "z_lift_offset": 0.0,
    "z_write_light_offset": 2.0,
    "z_write_normal_offset": 0.0,
    "z_write_bold_offset": -1.5,
    "z_min_allowed_offset": -3.0
  },
  "line_demo": {
    "start_pose": [82.858, -229.638, 752.628, 12.552, -0.323, 143.515],
    "end_pose": [132.858, -229.638, 752.628, 12.552, -0.323, 143.515]
  },
  "paper_line_demo": {
    "start_u": 0.25,
    "end_u": 0.75,
    "line_v": 0.5
  },
  "circle_demo": {
    "center_u": 0.5,
    "center_v": 0.5,
    "radius_u": 0.16,
    "radius_v": 0.16,
    "segments": 24,
    "vel": 50
  },
  "shape_demo": {
    "default_shape": "circle",
    "center_u": 0.5,
    "center_v": 0.5,
    "radius_u": 0.16,
    "radius_v": 0.16,
    "square_half_u": 0.16,
    "square_half_v": 0.16,
    "triangle_radius_u": 0.18,
    "triangle_radius_v": 0.18,
    "segments": 72,
    "vel": 12
  },
  "before_draw": {
    "start_pose": [-105.657, 275.606, 371.442, 179.379, 8.605, -113.274],
    "start_vel": 20
  },
  "svg_demo": {
    "svg_path": "assets/svg/tâm.svg",
    "u_min": 0.25,
    "u_max": 0.75,
    "v_min": 0.25,
    "v_max": 0.75,
    "samples_per_path": 120,
    "vel": 50
  },
  "svg_pipeline": {
    "svg_input_path": "assets/svg/tam.svg",
    "paper_origin_x": 0.0,
    "paper_origin_y": 0.0,
    "paper_width_mm": 100.0,
    "paper_height_mm": 100.0,
    "writing_z": 0.0,
    "hover_z": 20.0,
    "safe_z": 80.0,
    "sample_step_mm": 1.0,
    "point_spacing_mm": 1.0,
    "max_point_distance_mm": 1.0,
    "min_point_distance_mm": 0.05,
    "smoothing_enabled": false,
    "smoothing_window": 3,
    "curve_sample_resolution": 32,
    "simplify_tolerance": 0.05,
    "min_point_distance": 0.05,
    "preserve_aspect_ratio": true,
    "fit_width": true,
    "fit_height": true,
    "center_on_paper": true,
    "offset_x": 0.0,
    "offset_y": 0.0,
    "fit_to_drawable_bounds": true,
    "align_text_baseline": true,
    "baseline_candidate_ratio": 0.45,
    "baseline_target": "median",
    "flip_y": false,
    "invert_y": false,
    "allow_closed_paths": true,
    "max_strokes": 0,
    "max_points_per_stroke": 220
  },
  "calligraphy_pressure": {
    "enabled": true,
    "z_safe": 80.0,
    "z_pen_touch": 20.0,
    "z_thin_offset": 0.45,
    "z_normal_offset": -0.15,
    "z_thick_offset": -0.95,
    "downward_dy_threshold": 0.22,
    "upward_dy_threshold": -0.22,
    "horizontal_dy_threshold": 0.14,
    "invert_y": false,
    "pressure_smoothing": true,
    "max_z_change_per_mm": 0.07
  },
  "text_demo": {
    "mode": "font_skeleton",
    "continuous": false,
    "u_min": 0.2,
    "u_max": 0.8,
    "v_min": 0.2,
    "v_max": 0.8,
    "font_family": "Mistral",
    "font_path": "C:/Users/anhkh/Downloads/MISTRAL.TTF",
    "font_size": 1.0,
    "skeleton_raster_scale": 120,
    "skeleton_min_stroke_pixels": 8,
    "invert_y": true,
    "max_points_per_stroke": 120,
    "point_spacing": 0.025,
    "vel": 12,
    "travel_vel": 18,
    "travel_z_offset": 20.0
  },
  "after_draw": {
    "return_to_bottom_left": true,
    "return_corner": "bottom_left",
    "return_pose": [-105.657, 275.606, 371.442, 179.379, 8.605, -113.274],
    "return_vel": 20
  },
  "motion_strategy": {
    "mode": "new_spline",
    "approach_with_move_j": true,
    "approach_vel": 20,
    "draw_with_move_l": false,
    "fallback_to_blended_movel": true,
    "blend_radius": 2.0,
    "acceleration": 0.0,
    "spline_type": 1,
    "spline_average_time_ms": 2000
  },
  "smooth_writing": {
    "writing_speed_mm_s": 12,
    "travel_speed_mm_s": 18,
    "writing_z": 292.206,
    "hover_z": 312.206,
    "safe_z": 371.442,
    "point_spacing_mm": 1.0,
    "smoothing_tolerance": 0.35,
    "min_point_distance_mm": 0.25,
    "moving_average_window": 3,
    "blend_radius_mm": 2.0,
    "servo_period_ms": 8,
    "acceleration": 0.0,
    "corner_slowdown_angle_deg": 55.0,
    "min_corner_speed_factor": 0.45,
    "max_points_per_stroke": 220,
    "min_workspace_x": -500.0,
    "max_workspace_x": 500.0,
    "min_workspace_y": -600.0,
    "max_workspace_y": 600.0
  }
}
```

### POST /config/reload

Reload config từ file.

Response: giống `GET /config`.

### PATCH /config

Patch config bằng body bọc trong `data`.

Request body:

```json
{
  "data": {
    "default_vel": 15,
    "enable_robot_move": false,
    "paper": {
      "margin_mm": 15.0
    },
    "connection_policy": {
      "allow_raw_xmlrpc_motion": true
    }
  }
}
```

Response: toàn bộ config sau khi cập nhật.

## Robot

### GET /robot/ports

Kiểm tra các cổng robot theo cấu hình.

Response mẫu:

```json
{
  "robot_ip": "192.168.58.2",
  "ports": {
    "20003": true,
    "20004": true,
    "20005": false
  },
  "errors": {
    "20005": "[Errno 61] Connection refused"
  }
}
```

### GET /robot/status

Trạng thái robot qua controller chính.

Response:

```json
{
  "robot_ip": "192.168.58.2",
  "connected": true,
  "xmlrpc_ok": true,
  "tcp_pose": [0, 0, 0, 0, 0, 0],
  "error_code": [0, 0]
}
```

### GET /robot/raw_status

Trạng thái robot qua raw XML-RPC.

Response:

```json
{
  "robot_ip": "192.168.58.2",
  "connected": true,
  "controller_ip": "192.168.58.2",
  "tcp_pose": [0, 0, 0, 0, 0, 0],
  "error_code": [0, 0]
}
```

### POST /robot/moveL

Body:

```json
{
  "pose": [300.0, 0.0, 300.0, 180.0, 0.0, 90.0],
  "vel": 10.0
}
```

Response mẫu:

```json
{
  "enable_move": true,
  "allow_raw_xmlrpc_motion": true,
  "result": 0
}
```

### POST /robot/ik

Body:

```json
{
  "pose": [300.0, 0.0, 300.0, 180.0, 0.0, 90.0]
}
```

Response:

```json
{
  "pose": [300.0, 0.0, 300.0, 180.0, 0.0, 90.0],
  "connected": true,
  "joint": [0, -30, 90, 0, 60, 0]
}
```

### POST /robot/move/start

Body:

```json
{
  "vel": 20
}
```

Response mẫu:

```json
{
  "pose": [-105.657, 275.606, 371.442, 179.379, 8.605, -113.274],
  "enable_move": true,
  "allow_raw_xmlrpc_motion": true,
  "result": 0
}
```

### POST /robot/draw/shape

Body:

```json
{
  "shape_name": "square",
  "vel": 20
}
```

Shape hỗ trợ:

- `line_horizontal`
- `line_vertical`
- `line_diagonal_down`
- `line_diagonal_up`
- `circle`
- `square`
- `rectangle`
- `triangle`
- `tam`

Response mẫu:

```json
{
  "shape": "square",
  "pose_count": 5,
  "enable_move": true,
  "allow_raw_xmlrpc_motion": true,
  "result": []
}
```

### POST /robot/draw/line

Body:

```json
{
  "vel": 20
}
```

Response: thường có `pose_count`, `start_pose`, `return_pose`, `enable_move`, `allow_raw_xmlrpc_motion`, `result`.

### POST /robot/draw/circle

Body:

```json
{
  "vel": 20
}
```

Response: thường có `pose_count`, `start_pose`, `return_pose`, `enable_move`, `allow_raw_xmlrpc_motion`, `result`.

### POST /robot/draw/svg

Body có thể theo 3 kiểu:

```json
{
  "svg_path": "assets/svg/Nhan.svg",
  "vel": 12
}
```

```json
{
  "word_key": "Tâm",
  "vel": 12
}
```

```json
{
  "svg_paths": ["assets/svg/tam3.svg", "assets/svg/an.svg"],
  "vel": 12
}
```

`word_key` hiện map theo `config/word_library.json`:

- `Tâm`
- `Tri thức`
- `Sáng tạo`
- `Tương lai`
- `Công nghệ`
- `Khát vọng`

Response mẫu:

```json
{
  "source": ["assets/svg/Nhan.svg"],
  "stroke_count": 4,
  "pose_count": 180,
  "planned_stroke_count": 4,
  "planned_pose_count": 160,
  "paper_width": 199.053,
  "paper_height": 263.069,
  "start_pose": [-105.657, 275.606, 371.442, 179.379, 8.605, -113.274],
  "return_pose": [-105.657, 275.606, 371.442, 179.379, 8.605, -113.274],
  "motion_mode": "smooth",
  "enable_move": true,
  "allow_raw_xmlrpc_motion": true,
  "result": []
}
```

### POST /robot/draw/text

Body:

```json
{
  "text": "Tam",
  "continuous": false,
  "vel": 12
}
```

Response mẫu:

```json
{
  "source": "Tam",
  "stroke_count": 2,
  "pose_count": 120,
  "planned_stroke_count": 2,
  "planned_pose_count": 118,
  "paper_width": 199.053,
  "paper_height": 263.069,
  "start_pose": [-105.657, 275.606, 371.442, 179.379, 8.605, -113.274],
  "return_pose": [-105.657, 275.606, 371.442, 179.379, 8.605, -113.274],
  "motion_mode": "smooth",
  "enable_move": true,
  "allow_raw_xmlrpc_motion": true,
  "result": [],
  "continuous": false
}
```

### POST /robot/draw/text/outline

Viết chữ nhập từ bàn phím theo dạng outline font Times New Roman.

Body:

```json
{
  "text": "Happy New Year",
  "continuous": false,
  "vel": 12
}
```

Response mẫu:

```json
{
  "source": "Happy New Year",
  "stroke_count": 12,
  "pose_count": 320,
  "planned_pose_count": 300,
  "font_family": "Times New Roman",
  "text_mode": "outline",
  "motion_mode": "smooth",
  "enable_move": true,
  "allow_raw_xmlrpc_motion": true,
  "result": []
}
```

### POST /robot/draw/paper_corners

Body:

```json
{
  "corners": [
    [-72.905, 566.026, 254.059, 178.105, 6.628, -117.259],
    [57.222, 563.859, 254.065, 178.438, 5.884, -130.427],
    [54.994, 376.268, 254.059, -179.927, 2.518, -137.905],
    [-75.305, 379.196, 254.069, 179.554, 1.428, -118.339]
  ],
  "vel": 20
}
```

Response mẫu:

```json
{
  "pose_count": 4,
  "enable_move": true,
  "allow_raw_xmlrpc_motion": true,
  "result": []
}
```

## Trajectory Preview

### POST /trajectory/line/preview

Không cần body.

Response:

```json
{
  "start_pose": [0, 0, 0, 0, 0, 0],
  "end_pose": [1, 1, 1, 0, 0, 0],
  "return_pose": null,
  "use_measured_paper": true
}
```

### POST /trajectory/shape/preview

Body:

```json
{
  "shape_name": "circle"
}
```

Response:

```json
{
  "shape": "circle",
  "poses": [[0, 0, 0, 0, 0, 0], [1, 1, 1, 0, 0, 0]]
}
```

### POST /trajectory/svg/preview

Body:

```json
{
  "svg_path": "assets/svg/tam.svg"
}
```

Hoặc:

```json
{
  "word_key": "Tâm"
}
```

Response:

```json
{
  "svg_path": "assets/svg/tam.svg",
  "poses": [[0, 0, 0, 0, 0, 0], [1, 1, 1, 0, 0, 0]]
}
```

### POST /trajectory/text/preview

Body:

```json
{
  "text": "Tam",
  "continuous": true
}
```

Response:

```json
{
  "text": "Tam",
  "continuous": true,
  "stroke_count": 2,
  "poses": [[0, 0, 0, 0, 0, 0], [1, 1, 1, 0, 0, 0]]
}
```

### POST /trajectory/text/outline/preview

Preview chữ nhập từ bàn phím theo dạng outline font Times New Roman.

Body:

```json
{
  "text": "Happy New Year",
  "continuous": false
}
```

Response:

```json
{
  "text": "Happy New Year",
  "continuous": false,
  "font_family": "Times New Roman",
  "text_mode": "outline",
  "stroke_count": 12,
  "poses": [[0, 0, 0, 0, 0, 0], [1, 1, 1, 0, 0, 0]]
}
```

## Safety

### POST /safety/validate_pose

Body:

```json
{
  "pose": [300.0, 0.0, 300.0, 180.0, 0.0, 90.0]
}
```

Response:

```json
{
  "ok": true
}
```

### POST /safety/validate_poses

Body:

```json
{
  "poses": [[300.0, 0.0, 300.0, 180.0, 0.0, 90.0]]
}
```

Response:

```json
{
  "ok": true
}
```

### POST /safety/validate_paper_point

Body:

```json
{
  "corners": [
    [-72.905, 566.026, 254.059, 178.105, 6.628, -117.259],
    [57.222, 563.859, 254.065, 178.438, 5.884, -130.427],
    [54.994, 376.268, 254.059, -179.927, 2.518, -137.905],
    [-75.305, 379.196, 254.069, 179.554, 1.428, -118.339]
  ],
  "start_pose": [82.858, -229.638, 752.628, 12.552, -0.323, 143.515],
  "end_pose": [132.858, -229.638, 752.628, 12.552, -0.323, 143.515]
}
```

Response:

```json
{
  "ok": true,
  "start_inside": true,
  "end_inside": true
}
```

## Map nhanh cho frontend

- Dùng `GET /config` để load toàn bộ state ban đầu.
- Dùng `PATCH /config` để update một phần config theo object `data`.
- Dùng `POST /trajectory/*/preview` để preview data trước khi chạy robot.
- Dùng `POST /robot/*` cho motion thật hoặc kiểm tra robot.
- Dùng `POST /safety/*` để validate trước khi gửi motion.
