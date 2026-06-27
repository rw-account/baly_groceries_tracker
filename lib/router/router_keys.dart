// lib/router/router_keys.dart

import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final GlobalKey<NavigatorState> homeBranchNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'homeBranch');

final GlobalKey<NavigatorState> expiryBranchNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'expiryBranch');

final GlobalKey<NavigatorState> shoppingListBranchNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shoppingListBranch');
